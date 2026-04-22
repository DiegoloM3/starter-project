import pygame
import docker
import threading
import time
import httpx
import sys
from datetime import datetime

# Configuration & Styles
COLORS = {
    "bg": (10, 10, 15),
    "panel": (20, 20, 30),
    "neon_cyan": (0, 255, 255),
    "neon_magenta": (255, 0, 255),
    "green": (50, 255, 100),
    "red": (255, 50, 50),
    "text": (200, 200, 220),
    "grid": (40, 40, 60)
}

class ServiceStatus:
    def __init__(self, name, container_name):
        self.name = name
        self.container_name = container_name
        self.status = "UNKNOWN"
        self.cpu = "0%"
        self.memory = "0MB"

class SymmetryNexus:
    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((1000, 700))
        pygame.display.set_caption("SYMMETRY NEXUS | Command & Control")
        self.clock = pygame.time.Clock()
        self.font_main = pygame.font.SysFont("Consolas", 18)
        self.font_title = pygame.font.SysFont("Consolas", 32, bold=True)
        self.font_small = pygame.font.SysFont("Consolas", 14)
        
        self.docker_client = docker.from_env()
        self.services = [
            ServiceStatus("API GATEWAY", "fastapi-api-1"),
            ServiceStatus("MONGO DB", "fastapi-mongodb-1"),
            ServiceStatus("OLLAMA AI", "symmetry_ollama"),
            ServiceStatus("CADDY PROXY", "fastapi-caddy-1")
        ]
        
        self.logs = ["Initializing Nexus Systems...", "Connecting to Docker Engine..."]
        self.running = True
        self.ingesting = False
        
        # Start background monitor
        self.monitor_thread = threading.Thread(target=self._monitor_loop, daemon=True)
        self.monitor_thread.start()

    def _add_log(self, msg):
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.logs.append(f"[{timestamp}] {msg}")
        if len(self.logs) > 25:
            self.logs.pop(0)

    def _monitor_loop(self):
        while self.running:
            for service in self.services:
                try:
                    container = self.docker_client.containers.get(service.container_name)
                    service.status = container.status.upper()
                    stats = container.stats(stream=False)
                    
                    # Basic CPU/Mem calc
                    cpu_delta = stats['cpu_stats']['cpu_usage']['total_usage'] - stats['precpu_stats']['cpu_usage']['total_usage']
                    system_delta = stats['cpu_stats']['system_cpu_usage'] - stats['precpu_stats']['system_cpu_usage']
                    if system_delta > 0:
                        service.cpu = f"{(cpu_delta / system_delta) * 100:.1f}%"
                    
                    mem_bytes = stats['memory_stats'].get('usage', 0)
                    service.memory = f"{mem_bytes / 1024 / 1024:.1f}MB"
                except:
                    service.status = "OFFLINE"
            time.sleep(2)

    def _trigger_ingestion(self):
        self.ingesting = True
        self._add_log("Triggering AI News Ingestion...")
        try:
            # We call the local API
            response = httpx.post("https://uncovernews.ddns.net/api/v1/ingest/trigger", timeout=120.0)
            data = response.json()
            self._add_log(f"Ingestion Finished: {data.get('new_articles_count', 0)} items.")
        except Exception as e:
            self._add_log(f"Ingestion Failed: {str(e)}")
        finally:
            self.ingesting = False

    def _run_tests(self):
        self._add_log("Starting Backend Tests (pytest)...")
        try:
            container = self.docker_client.containers.get("fastapi-api-1")
            result = container.exec_run("pytest")
            self._add_log("Tests Finished.")
            # Show first lines of results
            lines = result.output.decode().split('\n')
            for line in lines[:5]:
                if line.strip(): self._add_log(f" > {line}")
        except Exception as e:
            self._add_log(f"Test Execution Failed: {str(e)}")

    def _check_ai(self):
        self._add_log("Probing Ollama Model (qwen2.5:3b)...")
        try:
            response = httpx.get("https://uncovernews.ddns.net/api/v1/ollama/api/tags")
            if response.status_code == 200:
                self._add_log("Ollama Status: ONLINE & READY")
            else:
                self._add_log(f"Ollama Status: ERROR {response.status_code}")
        except Exception as e:
            self._add_log(f"Ollama Probe Failed: {str(e)}")

    def draw(self):
        self.screen.fill(COLORS["bg"])
        
        # Header
        title_surf = self.font_title.render("SYMMETRY NEXUS", True, COLORS["neon_cyan"])
        self.screen.blit(title_surf, (30, 30))
        pygame.draw.line(self.screen, COLORS["neon_magenta"], (30, 75), (970, 75), 2)
        
        # Service Panels
        for i, service in enumerate(self.services):
            x = 30 + (i % 2) * 480
            y = 100 + (i // 2) * 120
            rect = pygame.Rect(x, y, 460, 100)
            pygame.draw.rect(self.screen, COLORS["panel"], rect, border_radius=8)
            
            # Status Indicator
            color = COLORS["green"] if service.status == "RUNNING" else COLORS["red"]
            pygame.draw.circle(self.screen, color, (x + 25, y + 25), 8)
            
            name_surf = self.font_main.render(service.name, True, COLORS["text"])
            self.screen.blit(name_surf, (x + 45, y + 15))
            
            status_surf = self.font_small.render(f"STATUS: {service.status}", True, color)
            self.screen.blit(status_surf, (x + 45, y + 40))
            
            stats_surf = self.font_small.render(f"CPU: {service.cpu} | MEM: {service.memory}", True, COLORS["grid"])
            self.screen.blit(stats_surf, (x + 45, y + 65))

        # Log Terminal
        log_rect = pygame.Rect(30, 360, 680, 310)
        pygame.draw.rect(self.screen, (5, 5, 10), log_rect, border_radius=4)
        pygame.draw.rect(self.screen, COLORS["grid"], log_rect, 1, border_radius=4)
        
        for i, log in enumerate(self.logs):
            log_surf = self.font_small.render(log, True, (0, 200, 100))
            self.screen.blit(log_surf, (40, 370 + i * 18))

        # Action Buttons
        buttons = [
            ("TRIGGER INGESTION", self._trigger_ingestion, COLORS["neon_magenta"]),
            ("RUN BACKEND TESTS", self._run_tests, COLORS["neon_cyan"]),
            ("CHECK AI HEALTH", self._check_ai, COLORS["green"]),
        ]

        for i, (label, func, color) in enumerate(buttons):
            btn_rect = pygame.Rect(730, 360 + i * 70, 240, 60)
            is_hover = btn_rect.collidepoint(pygame.mouse.get_pos())
            
            draw_color = color if is_hover else COLORS["panel"]
            pygame.draw.rect(self.screen, draw_color, btn_rect, border_radius=8)
            
            # Special case for ingesting state
            display_label = label
            if label == "TRIGGER INGESTION" and self.ingesting:
                display_label = "INGESTING..."

            btn_text = self.font_main.render(display_label, True, COLORS["text"])
            self.screen.blit(btn_text, (btn_rect.centerx - btn_text.get_width()//2, btn_rect.centery - btn_text.get_height()//2))

        # Scanline Effect
        for i in range(0, 700, 4):
            pygame.draw.line(self.screen, (0, 0, 0, 50), (0, i), (1000, i))

        pygame.display.flip()

    def run(self):
        while self.running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.running = False
                if event.type == pygame.MOUSEBUTTONDOWN:
                    buttons = [
                        pygame.Rect(730, 360, 240, 60),
                        pygame.Rect(730, 430, 240, 60),
                        pygame.Rect(730, 500, 240, 60),
                    ]
                    if buttons[0].collidepoint(event.pos):
                        if not self.ingesting:
                            threading.Thread(target=self._trigger_ingestion).start()
                    elif buttons[1].collidepoint(event.pos):
                        threading.Thread(target=self._run_tests).start()
                    elif buttons[2].collidepoint(event.pos):
                        threading.Thread(target=self._check_ai).start()
            
            self.draw()
            self.clock.tick(30)
        
        pygame.quit()

if __name__ == "__main__":
    SymmetryNexus().run()

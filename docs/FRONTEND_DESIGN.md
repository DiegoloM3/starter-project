# Daily News • Design System



V1.0 • Typography, Color, Spacing, and Elevation Specs

[News Reader DS]

---

## Colour Palette



### PRIMARY ACCENT



* **Primary Purple:** #7C3AED



### SEMANTIC COLOURS



* **Success:** #10B981


* **Warning:** #F59E0B


* **Danger:** #EF4444


* **Info:** #3B82F6



### LIGHT THEME SURFACES



* **Background:** #F9F8F6


* **Surface:** #FFFFFF


* **Card:** #FFFFFF


* **Divider:** #E5E7EB



### DARK THEME SURFACES



* **Background:** #0B0A0F


* **Surface:** #16141F


* **Card:** #16141F


* **Divider:** #2A263D



### STATUS GREYSCALE EQUIV.



* **Published:** #4B5563 (Dark)


* **Draft:** #E5E7EB (Light)



---

## Type Scale



* **DISPLAY** (`Instrument Serif • 400 • 38px`)


Daily News


* **HEADLINE** (`Instrument Serif • 400 • 26px`)


The Neon Horizon: How AI Transformed Twilight's Skyline


* **TITLE** (`Inter • 600 • 18px`)


Saved Articles


* **BODY** (`Inter • 400 • 15px`)


The intersection of algorithmic rendering and urban architecture...


* **LABEL** (`Inter • 600 • 13px`)


WRITE ARTICLE


* **CAPTION** (`Inter • 500 • 11px`)


OCT 24, 2026 • 3H AGO



---

## Spacing Scale (4pt Base)



* **4**

* **8**

* **12**

* **16**

* **20**

* **24**

* **32**

* **40**


---

## Corner Radius



* **Cards:** 16px Radius


* **Buttons:** 30px Radius


* **Sheets:** 32px Radius



---

## Elevation / Shadows



* **Card Shadow:** y:4, blur:12, 6% Opacity


* **Sheet Shadow:** y:-10, blur:24, 25% Opacity

Aquí tienes la transcripción de la imagen:

# USER JOURNEY MAP



## Reader → Writer Flow



From reading without an account to publishing in the Community feed

---

1. **01. Browse News:** Paso 1.
   Reader opens the app, reads Daily News feed (no account needed).


2. **02. Tap Write:** Paso 2.
   Reader taps the floating 'Write' action button on screen.


3. **03. Sign-in Prompt:** Paso 3.
   Bottom sheet overlay appears inviting them to join the conversation.


4. **04. Create Account:** Paso 4.
   Reader enters credentials and signs up for a free creator profile.


5. **05. Write Article:** Paso 5.
   Now configured as a writer, drafts the article in the rich editor workspace.


6. **06. Publish:** Paso 6.
   Taps publish and sees the success celebration screen.


7. **07. Live in Feed:** Paso 7.
   The article goes live instantly in the Community feed for everyone.


---

> **Note:** Reading is always free. Writing needs a free account.
>
>
> 
> 
> Y la clave para que no se peleen: el brillo va en la capa de presentación (tipografía, imagen, color, movimiento) y la claridad en la de interacción. Una pantalla puede ser preciosa y aun así etiquetar sus botones.

2. Propuse cambiar la navegación. Hoy hay cuatro iconos sin etiqueta apiñados en el AppBar — eso reprueba el test de la abuela de entrada. El brief pide bottom navigation con etiquetas: News / Community / Saved / Account, más un FAB "Write". Es también lo que el chico de 18 espera encontrar.

3. Pantalla nueva vs. misma pantalla — lo resolví con una regla de peso, no caso por caso:

┌──────────────────────────────────────────────────────┬──────────────────────────────────────────────┐
│                  Peso de la acción                   │                    Patrón                    │
├──────────────────────────────────────────────────────┼──────────────────────────────────────────────┤
│ Publicar (público, se siente irreversible)           │ Pantalla completa con el check verde animado │
├──────────────────────────────────────────────────────┼──────────────────────────────────────────────┤
│ Guardar borrador con el botón, borrar, cerrar sesión │ Snackbar                                     │
├──────────────────────────────────────────────────────┼──────────────────────────────────────────────┤
│ Autosave                                             │ Texto ambiental — jamás interrumpe           │
├──────────────────────────────────────────────────────┼──────────────────────────────────────────────┤
│ Borrar, despublicar                                  │ Diálogo                                      │
├──────────────────────────────────────────────────────┼──────────────────────────────────────────────┤
│ Pedir cuenta al tocar "Write"                        │ Bottom sheet (invitación, no muro)           │
└──────────────────────────────────────────────────────┴──────────────────────────────────────────────┘

Lo del autosave es deliberado y va subrayado en el brief: acabamos de arreglar el bug donde interrumpía al escritor. Que un generador de UI lo convierta en un toast sobre el teclado sería reintroducirlo.
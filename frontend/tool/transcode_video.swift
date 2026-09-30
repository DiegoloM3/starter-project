// Re-encodes a screen recording as H.264 at a given width and bitrate, small enough for git.
// Usage: swift tool/transcode_video.swift <input> <output.mp4> <width> <kbps>
import AVFoundation

let args = CommandLine.arguments
let asset = AVURLAsset(url: URL(fileURLWithPath: args[1]))
let output = URL(fileURLWithPath: args[2])
let width = Double(args[3])!
let bitrate = Int(args[4])! * 1000
try? FileManager.default.removeItem(at: output)

let track = asset.tracks(withMediaType: .video)[0]
let natural = track.naturalSize.applying(track.preferredTransform)
let scale = width / abs(natural.width)
let height = (abs(natural.height) * scale / 2).rounded() * 2

let reader = try! AVAssetReader(asset: asset)
let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
])
reader.add(readerOutput)

let writer = try! AVAssetWriter(outputURL: output, fileType: .mp4)
let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoScalingModeKey: AVVideoScalingModeResizeAspect,
    AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: bitrate,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
        AVVideoMaxKeyFrameIntervalKey: 120,
    ],
])
input.transform = .identity
input.expectsMediaDataInRealTime = false
writer.add(input)
writer.shouldOptimizeForNetworkUse = true

reader.startReading()
writer.startWriting()
writer.startSession(atSourceTime: .zero)
let done = DispatchSemaphore(value: 0)
input.requestMediaDataWhenReady(on: DispatchQueue(label: "transcode")) {
    while input.isReadyForMoreMediaData {
        if let sample = readerOutput.copyNextSampleBuffer() {
            input.append(sample)
        } else {
            input.markAsFinished()
            writer.finishWriting { done.signal() }
            return
        }
    }
}
done.wait()
print(writer.status == .completed ? "ok \(Int(width))x\(Int(height))" : "failed: \(String(describing: writer.error))")

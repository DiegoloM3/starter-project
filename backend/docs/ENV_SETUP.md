# Environment Setup

## Firebase Configuration

### Option 1: Using FlutterFire CLI (Recommended)

The easiest way to configure Firebase:

```bash
cd frontend
flutterfire configure
```

This automatically generates `lib/firebase_options.dart` with all necessary configuration.

### Option 2: Manual Configuration

If needed, get your Firebase config from Firebase Console → Project Settings → Your Apps:
- `apiKey`
- `authDomain`
- `projectId`
- `storageBucket`
- `messagingSenderId`
- `appId`

## Cloudinary Configuration

### Required for Image Uploads

Only the cloud name and upload preset are needed for client-side uploads:

| Variable | Description | Where to Find |
|----------|-------------|---------------|
| `CLOUDINARY_CLOUD_NAME` | Your cloud name | Dashboard → Cloud Name |
| `CLOUDINARY_UPLOAD_PRESET` | Unsigned upload preset name | Settings → Upload → Upload Presets |

**Note:** API Key and Secret are NOT needed for unsigned uploads from the Flutter app.

### Setting Up Upload Preset

1. Go to Cloudinary Dashboard → Settings → Upload → Upload Presets
2. Click "Add upload preset"
3. Configure:
   - **Preset name:** Choose a name (e.g., `xg3gxg9w`)
   - **Signing Mode:** Unsigned
   - **Folder:** `articles` (for article cover images)
4. Save and note the preset name

## Flutter Environment Setup

### Running with dart-define (Recommended)

```bash
cd frontend

flutter run -d <device_id> \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=your_preset_name
```

### Example

```bash
flutter run -d emulator-5554 \
  --dart-define=CLOUDINARY_CLOUD_NAME=dgi3u8chm \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=xg3gxg9w
```

### Using Shell Script

Create `run_dev.sh` in the frontend folder:

```bash
#!/bin/bash
DEVICE_ID=${1:-emulator-5554}

flutter run -d $DEVICE_ID \
  --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=your_preset_name
```

Usage:
```bash
chmod +x run_dev.sh
./run_dev.sh                    # Default device
./run_dev.sh chrome             # Chrome
./run_dev.sh <device-id>        # Specific device
```

## Security Notes

- ✅ Unsigned upload presets are safe for client-side use
- ✅ Configure allowed folders and file types in Cloudinary settings
- ⚠️ Never commit actual credentials to git
- ⚠️ For production, consider server-side signed uploads for additional control

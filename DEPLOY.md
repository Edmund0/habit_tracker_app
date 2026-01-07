# Deploying Momentum to GitHub Pages

This app is configured to automatically deploy to GitHub Pages whenever you push to the `main` branch.

## Setup Instructions

### 1. Enable GitHub Pages in Repository Settings

1. Go to your repository on GitHub: https://github.com/Edmund0/habit_tracker_app
2. Click **Settings** → **Pages** (in the left sidebar)
3. Under **Build and deployment**:
   - Source: Select **GitHub Actions**
4. Save the settings

### 2. Push Your Code

The deployment workflow will automatically run when you push to the `main` branch:

```bash
git add .
git commit -m "Setup GitHub Pages deployment"
git push origin main
```

### 3. Monitor Deployment

1. Go to the **Actions** tab in your repository
2. You'll see the "Deploy to GitHub Pages" workflow running
3. Once complete (green checkmark), your app will be live at:
   **https://edmund0.github.io/habit_tracker_app/**

## Manual Deployment

To manually trigger a deployment:

1. Go to **Actions** tab
2. Click **Deploy to GitHub Pages** workflow
3. Click **Run workflow** button
4. Select the `main` branch and click **Run workflow**

## Local Testing

To test the web build locally:

```bash
flutter build web --release
cd build/web
python3 -m http.server 8000
```

Then open http://localhost:8000 in your browser.

## Troubleshooting

### Build Fails
- Check the Actions tab for error messages
- Ensure all dependencies in `pubspec.yaml` are compatible with web
- Run `flutter build web` locally to test

### App Loads But Shows Errors
- Check browser console for JavaScript errors
- Verify base href is set correctly in the workflow
- Clear browser cache and hard reload (Cmd+Shift+R)

### 404 Error on Refresh
This is normal for GitHub Pages with Flutter web apps. The app uses client-side routing.
Users should bookmark the root URL: https://edmund0.github.io/habit_tracker_app/

## Workflow Files

- `.github/workflows/deploy-web.yaml` - Builds and deploys to GitHub Pages
- `.github/workflows/flutter.yaml` - Runs tests and analysis on PRs


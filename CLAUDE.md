# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application named "web3_demo" - a Web3 demonstration app with support for blockchain chains and transaction history viewing. The app uses a bottom navigation structure with two main pages and includes dark/light theme switching.

## Development Commands

### Setup
```bash
flutter pub get              # Install dependencies
```

### Running the App
```bash
flutter run                  # Run on connected device/emulator
flutter run -d chrome        # Run in Chrome (web)
flutter run -d windows       # Run on Windows desktop
```

### Testing
```bash
flutter test                 # Run all tests
flutter test test/widget_test.dart  # Run specific test file
```

### Code Analysis
```bash
flutter analyze              # Run static analysis with flutter_lints
```

### Building
```bash
flutter build apk            # Build Android APK
flutter build appbundle      # Build Android App Bundle
flutter build windows        # Build Windows desktop app
```

## Architecture

### State Management
The app uses **ValueNotifier** for simple reactive state management:
- `selectedPageNotifier` (lib/data/notifiers.dart) - Controls bottom navigation page selection
- `isDarkModeNotifier` (lib/data/notifiers.dart) - Controls theme mode (dark/light)
- `chainsNotifier` (lib/data/notifiers/support_chain_notifier.dart) - Stores blockchain chains list
- `chainsLoadingNotifier` (lib/data/notifiers/support_chain_notifier.dart) - Tracks chain loading state
- `chainsErrorNotifier` (lib/data/notifiers/support_chain_notifier.dart) - Stores chain fetch error messages

State is persisted using `shared_preferences` for theme preferences.

### Navigation Structure
- **WelcomePage** (entry point) → Shows Lottie animation and "Get Started" button
- **WidgetTree** (main container) → Hosts AppBar, body with page switcher, and bottom navigation
- Two main pages accessed via bottom navigation:
  1. **SupportChainPage** - Fetches and displays supported blockchain chains from OKX API with pull-to-refresh
  2. **TransitionHistoryPage** - Shows transaction history

### Key Directories
- `lib/views/pages/` - Main application pages
- `lib/widgets/` - Reusable widgets (navbar, chain list items)
- `lib/data/` - State notifiers, constants, models, and services
  - `lib/data/api/` - API clients (Dio client, OKX chain API)
  - `lib/data/models/` - Data models (blockchain chains)
  - `lib/data/services/` - Business logic layer (blockchain chain service)
  - `lib/data/notifiers/` - ValueNotifier instances for state management
- `assets/lotties/` - Lottie animation files
- `assets/images/` - Image assets

### Design Patterns
- Uses `ValueListenableBuilder` to rebuild UI when notifiers change
- Navigation via `Navigator.push()` from WelcomePage to WidgetTree
- Bottom navigation uses `NavigationBar` with `NavigationDestination` items
- Theme switching updates notifier and persists to SharedPreferences

### Dependencies
- `lottie` - Animation rendering for welcome screen
- `shared_preferences` - Local data persistence for theme mode
- `dio` - HTTP client for API requests to OKX blockchain API
- `crypto` - HMAC SHA256 signature generation for API authentication
- `flutter_lints` - Enforces Flutter best practices

### Network Configuration
The app supports proxy configuration for accessing external APIs:
- **Proxy Config**: `lib/data/config/proxy_config.dart` - Enable and configure proxy settings
- **Dio Client**: Automatically uses proxy when enabled
- **Timeout**: 30 seconds for connection and receive operations
- See `PROXY_SETUP.md` for detailed proxy configuration instructions

### API Integration
The app integrates with the OKX Web3 API:
- **Endpoint**: `https://web3.okx.com/api/v5/wallet/chain/supported-chains`
- **Authentication**: Uses HMAC SHA256 signature with API Key, Secret Key, and Passphrase
- **Client**: `OkxChainApiClient` (lib/data/api/okx_chain_api_client.dart) - Generates authentication headers
- **Service**: `BlockchainChainService` (lib/data/services/blockchain_chain_service.dart) - Provides caching and error handling
- **Models**: `BlockchainChain` and `BlockchainChainResponse` (lib/data/models/blockchain_chain.dart)
- **Configuration**: API credentials stored in `lib/data/config/api_credentials.dart` (see OKX_API_SETUP.md)

## Code Organization
The app follows standard Flutter project structure with clear separation:
- State management centralized in `lib/data/notifiers/`
- UI constants in `lib/data/constants.dart`
- Pages isolated in `lib/views/pages/`
- Reusable widgets in `lib/widgets/`
- API layer in `lib/data/api/` (Dio client, API clients)
- Service layer in `lib/data/services/` (business logic, caching)
- Data models in `lib/data/models/` (JSON serialization)

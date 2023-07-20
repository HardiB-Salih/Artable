# Artable - Art Selling Application

Artable is a sophisticated art and photograph selling application that allows users to browse and purchase stunning artworks from various artists. The app leverages Firebase's Firestore and Storage services for data storage, Firebase Functions for handling server-side logic, Stripe for secure payment processing, and Grid for efficient email handling. The app is developed using UIKit and Swift and integrates external libraries using CocoaPods.

## Features

- **Art and Photograph Showcase**: Browse a vast collection of captivating artworks and photographs from talented artists.
- **Artwork Details**: View detailed information about each artwork, including artist name, description, and price.
- **User Authentication**: Register and log in to the app securely using Firebase Authentication.
- **Cart Functionality**: Add artworks to the cart and proceed to checkout for purchasing.
- **Secure Payments**: Make seamless and secure payments using the Stripe payment gateway.
- **Order History**: Keep track of past orders and access order details in the app.
- **Email Notifications**: Receive email notifications using Grid to stay updated about new artworks and order status.

## Getting Started

To set up the Artable app on your local development environment, follow these steps:

### Prerequisites

- Xcode: Ensure you have the latest version of Xcode installed on your macOS system.
- CocoaPods: Install CocoaPods for dependency management. If you haven't installed it, run:

```bash
sudo gem install cocoapods
```

### Installation

1. Clone the Artable repository to your local machine using the following command:

```bash
git clone https://github.com/your-username/artable.git
```

2. Navigate to the project directory:

```bash
cd artable
```

3. Install the required dependencies using CocoaPods:

```bash
pod install
```

4. Open the Xcode workspace:

```bash
open Artable.xcworkspace
```

### Firebase Configuration

To use Firebase services (Firestore, Storage, Functions), set up a Firebase project on the Firebase Console and configure the necessary services. Add the `GoogleService-Info.plist` file to the Xcode project for Firebase integration.

### Stripe Configuration

Sign up for a Stripe account and obtain the necessary API keys for secure payment processing. Update the Stripe API keys in the app to enable payment functionality.

### Build and Run

1. Select the desired simulator or a connected device in Xcode.

2. Press the "Build and Run" button (or `Cmd + R`) to build and run the Artable app on your chosen device.


## Feedback and Support

If you encounter any issues or have suggestions for improvement, feel free to open an issue on the GitHub repository. Your feedback and contributions are valuable to enhance the Artable app.

## License

The Artable app is open-source and distributed under the [MIT License](https://innovativecandor.com/mit_license/). You are welcome to use, modify, and distribute the code as per the terms of the license.

---

Thank you for using the Artable app! We hope you enjoy exploring and discovering beautiful artworks from talented artists. Should you have any questions or need assistance, feel free to reach out. Happy art shopping! 🎨🖼️

# 🛒 Voice-Driven E-Commerce Platform

A full-stack e-commerce web application with a **hands-free voice control layer**, so shoppers can browse, manage their cart and wishlist, place orders, and even write product reviews just by speaking.

Built as a graduation project.


---

## ✨ Features

- **Product catalog** with categories (Electronics, Groceries, Wearings)
- **Shopping cart**, **wishlist**, and **order history**
- **User accounts**: registration, login (JWT authentication), profile, saved addresses
- **Admin dashboard** for managing products, categories, orders, users, and reviews, plus analytics
- **Checkout and order management** (place order, view orders, cancel pending orders)
- **Product reviews** with ratings, titles, comments, and recommendations
- **Voice control**: navigate and operate the whole store by speaking (see [Voice Commands](#-voice-commands))

---

## 🧰 Tech Stack

| Layer     | Technology                                        |
|-----------|---------------------------------------------------|
| Frontend  | Next.js, React, react-hot-toast, React Context    |
| Backend   | Java, Spring Boot, Spring Security (JWT), Gradle, Swagger |
| Database  | MySQL                                             |
| Voice     | Speech recognition via the Web Speech API (Google speech service in Chrome) |

---

## 📁 Project Structure

```
.
├── BACKEND/
│   ├── demo/                          # Spring Boot application (Gradle)
│   │   ├── assets/                    # Product images (Clothes, Electronics, Groceries)
│   │   ├── src/main/java/com/example/ecodb/
│   │   │   ├── config/                # Security, Swagger, web and async config, data initializer
│   │   │   ├── Controller/            # REST controllers (auth, products, cart, orders, ...)
│   │   │   ├── dto/                   # Request / response objects
│   │   │   ├── exception/             # Global exception handling
│   │   │   ├── Model/                 # JPA entities
│   │   │   ├── Repository/            # Spring Data repositories
│   │   │   ├── security/              # JWT authentication
│   │   │   ├── Service/               # Business logic (+ impl/)
│   │   │   └── util/
│   │   ├── src/main/resources/
│   │   │   └── application.properties
│   │   ├── build.gradle
│   │   └── gradlew / gradlew.bat
│   └── uploads/products/              # Uploaded product images
├── DATABASE/
│   ├── UPDATED_ADMIN_DBCODE.sql       # MySQL schema + seed data
│   ├── FinalGPSchema.mwb              # MySQL Workbench model
│   └── MysqlSchema.png, class digram.png, Schemas/   # Database and class diagrams
└── ecommerce/                         # Next.js frontend
    ├── components/                    # UI components (Navbar, Cart, Reviews, SpeechController, ...)
    ├── context/                       # Global state (StateContext)
    ├── lib/                           # API client, Stripe helper, utilities
    ├── pages/
    │   ├── admin/                     # Admin dashboard (analytics, products, orders, users, ...)
    │   ├── api/                       # Next.js API routes (Stripe)
    │   ├── order/, order-confirmation/, product/
    │   └── index, login, register, profile, orders, wishlist, checkout, search, ...
    ├── public/                        # Static assets
    ├── styles/                        # CSS modules and global styles
    ├── utils/speechUtils.js
    ├── .env.local
    └── package.json
```

---

## 🚀 Getting Started

### Prerequisites

- Java 17+ (or the version your project targets)
- Gradle (the included Gradle wrapper is enough)
- Node.js 18+ and npm
- MySQL 8+
- A Chromium-based browser (Chrome recommended) with a working microphone

### 1. Database

The schema and seed data are included in a single script. Just run it against your local MySQL server:

```bash
mysql -u root -p < DATABASE/UPDATED_ADMIN_DBCODE.sql
```

You can also open the file in MySQL Workbench and execute it.

### 2. Backend (Spring Boot + Gradle)

The backend's `application.properties` is already configured with local `localhost` links, so no extra setup is needed. If your local MySQL username or password differ from the ones in that file, update them there.

```bash
cd BACKEND/demo
./gradlew bootRun        # on Windows: gradlew.bat bootRun
```

The API starts on `http://localhost:8080` by default.

### 3. Frontend (Next.js)

The frontend's `.env.local` is already included and points to the local backend, so you can start right away:

```bash
cd ecommerce
npm install
npm run dev
```

Open `http://localhost:3000`.

---

## 🎤 Voice Commands

The voice controller (`SpeechController`) listens continuously once the page loads and shows a pulsing 🎤 indicator with the live transcript. **Allow microphone access** when your browser asks.

### Scrolling & navigation

| Say                      | What it does                                     |
|--------------------------|--------------------------------------------------|
| `scroll down`            | Starts continuous smooth scrolling down          |
| `scroll up`              | Starts continuous smooth scrolling up            |
| `stop`                   | Stops scrolling                                  |
| `top`                    | Jumps to the top of the page                     |
| `bottom`                 | Jumps to the bottom of the page                  |
| `back`                   | Goes to the previous page                        |
| `home` / `all products`  | Goes to the home page and shows all products     |

### Browsing products

| Say                                    | What it does                                  |
|----------------------------------------|-----------------------------------------------|
| `electronics`                          | Filters to the Electronics category           |
| `groceries` / `grocery`                | Filters to the Groceries category            |
| `wearings`                             | Filters to the Wearings category             |
| `item <number>` (e.g. `item three`)    | Opens the product with that number (1–20)     |

### Product page & cart

| Say                              | What it does                                         |
|----------------------------------|------------------------------------------------------|
| `plus` / `minus`                 | Increases / decreases the product quantity           |
| `add`                            | Adds the current product to the cart                 |
| `shopping`                       | Opens the shopping cart                              |
| `remove <number>`                | Removes the cart item at that position (1–10)        |
| `close`                          | Closes the cart and the user dropdown menu           |
| `check out`                      | Clicks the checkout button in the cart               |
| `make order` / `place order`     | Places the order on the checkout page                |

### Wishlist

| Say                     | What it does                                                                  |
|-------------------------|-------------------------------------------------------------------------------|
| `list`                  | Opens the wishlist page                                                       |
| `like <number>`         | Adds the numbered product to the wishlist (listing and product pages)         |
| `unlike <number>`       | Removes the numbered product from the wishlist                                |
| `add all`               | Adds every wishlist item to the cart (navigates to the wishlist if needed)    |

### Orders

| Say                      | What it does                                                    |
|--------------------------|-----------------------------------------------------------------|
| `orders`                 | Opens the orders page                                           |
| `view all orders`        | Opens the full order list                                       |
| `view <number>`          | Opens the details of the numbered order (on the orders page)    |
| `cancel order`           | Cancels the order on the order-details page (pending orders)    |
| `cancel <number>`        | Cancels the numbered order from the orders page                 |

### Account & forms

| Say                                   | What it does                                                         |
|---------------------------------------|----------------------------------------------------------------------|
| `menu`                                | Opens the user menu (goes to login if signed out)                    |
| `profile`                             | Opens the profile page                                               |
| `register` / `sign up`                | Opens the registration page                                          |
| `sign in` / `login`                   | Opens the login page                                                 |
| `first name`, `last name`             | Focuses that form field                                              |
| `email`                               | Focuses the email field                                              |
| `email <name>`                        | Focuses the email field and fills a sample address (`<name>.doe@example.com`) |
| `password`, `confirm password`        | Focuses the password / confirm-password field                        |
| `refresh`                             | Clears the field currently focused                                   |
| `exit` / `unfocus`                    | Leaves the focused input field                                       |

**Dictation:** when a text field is focused, anything you say is typed into it (password and email fields are intentionally excluded). Say `exit` to leave the field and return to command mode.

### Writing a review by voice

1. Say **`review`** to open the review form.
2. **Rating:** say a number from one to five.
3. **Title:** just speak, and your words are added to the title. Say **`next section`** when done.
4. **Comment:** just speak, and your words are added to the comment. Say **`next section`** when done.
5. **Recommendation:** say **`yes`** or **`no`**.
6. Say **`submit`** to post the review.

While reviewing, **`clear`** wipes the current text and **`cancel`** exits the review. An on-screen panel shows the current step and available commands.

### How the voice layer works

- Uses the browser's `SpeechRecognition` API in continuous mode with interim results, and automatically restarts if the recognizer stops.
- **Transcript cleanup:** removes repeated words and stuttered phrases (regex plus Levenshtein-based similarity) so dictated text stays clean.
- **Duplicate protection:** repeated recognitions of the same command are ignored, with extra guards for sensitive actions (`add all`, `remove`, `check out`, `make order`, `item`).
- **Partial-phrase handling:** very short or incomplete transcripts (for example "ex" before "exit") are held briefly instead of triggering the wrong command.
- Voice actions work by finding and clicking the matching UI elements (via `data-product-number` attributes and CSS class selectors), so the voice layer stays decoupled from the page components.

---

## 🗺️ Roadmap

- Complete the remaining pages and polish the UI
- Make the login and form voice flow more reliable
- Broader browser support for voice control
- Add automated tests

---

## 📝 Notes

- This project was built as a graduation project and serves as a proof of concept, so it focuses on demonstrating the core ideas rather than being production-ready.
- Voice control relies on the browser's built-in speech recognition and is best experienced in **Google Chrome**. It also runs in **Microsoft Edge**, with slightly reduced accuracy. It is not currently available in **Firefox** or **Brave**.
- Voice commands for login and form filling are basic for now, so typing is recommended for signing in.

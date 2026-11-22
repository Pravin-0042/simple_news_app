# Simple News App

A Flutter app for browsing the latest spaceflight news using the [Spaceflight News API](https://api.spaceflightnews.net/v4/).

The app includes a Discover feed, article search, filters, and a detail screen where you can read article summaries and open the original publisher's page.

## Features

- Browse articles with pagination and pull-to-refresh.
- Search articles by title.
- Filter articles by topic, source, and publication date.
- Sort articles by publication date.
- View article images, publisher details, author names, and summaries.
- Swipe between articles on the detail screen.
- Open the original article in a browser.
- Handle loading, empty, and network error states.

## Screenshots

Add screenshots from the running app:

Screens & Screenshots

Discover - `screenshots/discover.png`  
Search and filters - `screenshots/search_filters.png`
Article details - `screenshots/article_detail.png`

## Built With

- Flutter and Dart
- BLoC / Cubit for state management
- Dio for API requests
- GetIt for dependency injection
- GoRouter for navigation
- Cached Network Image for article images
- URL Launcher for external links

## Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── di/
│   ├── errors/
│   ├── network/
│   ├── router/
│   └── theme/
└── features/
    └── news/
        ├── data/
        ├── domain/
        └── presentation/
```

The project follows MVVM-style separation with repository-based data access. Cubits handle screen state, repositories handle API communication, and the UI is kept separate from the data layer.

## API

This project uses the Spaceflight News API v4.

- `GET /articles/` – Fetch articles.
- `GET /articles/?title_contains={query}` – Search by title.
- `GET /articles/{id}/` – Fetch an article's latest details.

API documentation: https://api.spaceflightnewsapi.net/v4/

## Getting Started

Make sure Flutter is installed and your Android or iOS development environment is configured.

Clone the repository and run:

```bash
flutter pub get
flutter run
```

To check the available devices:

```bash
flutter devices
```

## Notes

- Topic filters use keywords from article titles and summaries.
- Search by summary and the other filters work with articles already loaded in the app.
- Author avatars use initials because the API response does not include author images.
- Bookmarks are currently stored only in memory.
- The app displays the summary provided by the API; the full article opens on the publisher's website.

## Manual Checks

- Browse and refresh the Discover feed.
- Search for an article and clear the search.
- Try the topic and advanced filters.
- Scroll to load more articles.
- Open an article and swipe between articles.
- Open the original publisher page.
- Check the app with missing images or article details.

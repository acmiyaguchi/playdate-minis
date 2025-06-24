# Wikipedia Data API Structure Reference

This document outlines the structure of the JSON data feed from Wikipedia, as exemplified by the file for June 23, 2025. The root of the JSON is an object containing five main keys.

## Top-Level Keys

The root object contains the following five properties:

| Key         | Type            | Description                                                             |
| :---------- | :-------------- | :---------------------------------------------------------------------- |
| `tfa`       | `Object`        | Contains data for "Today's Featured Article".                           |
| `mostread`  | `Object`        | Contains a list of the most-viewed articles for the day.                |
| `image`     | `Object`        | Contains data for the "Image of the Day".                               |
| `news`      | `Array<Object>` | An array of objects, each representing a current news story.            |
| `onthisday` | `Array<Object>` | An array of objects, each representing a historical event on this date. |

---

## 1. `tfa` (Today's Featured Article) Object

This object contains comprehensive metadata for a single featured Wikipedia article.

| Key             | Type      | Description                                                                                  |
| :-------------- | :-------- | :------------------------------------------------------------------------------------------- |
| `type`          | `String`  | The type of content, e.g., "standard".                                                       |
| `title`         | `String`  | The canonical page title.                                                                    |
| `displaytitle`  | `String`  | The title formatted for display, may contain HTML.                                           |
| `namespace`     | `Object`  | Contains the namespace `id` and `text`.                                                      |
| `wikibase_item` | `String`  | The ID for the corresponding WikiData item.                                                  |
| `pageid`        | `Integer` | The unique ID of the Wikipedia page.                                                         |
| `thumbnail`     | `Object`  | An object containing the `source` (URL), `width`, and `height` of the thumbnail image.       |
| `originalimage` | `Object`  | An object containing the `source` (URL), `width`, and `height` of the full-resolution image. |
| `lang`          | `String`  | The language code of the article (e.g., "en").                                               |
| `dir`           | `String`  | The text direction (e.g., "ltr").                                                            |
| `revision`      | `String`  | The revision ID of the page.                                                                 |
| `tid`           | `String`  | A unique identifier for the transaction.                                                     |
| `timestamp`     | `String`  | The ISO 8601 timestamp of the last revision.                                                 |
| `description`   | `String`  | A brief description of the article's subject.                                                |
| `coordinates`   | `Object`  | An object containing `lat` (latitude) and `lon` (longitude) if available.                    |
| `content_urls`  | `Object`  | Contains `desktop` and `mobile` URLs for the page, revisions, edit, and talk pages.          |
| `extract`       | `String`  | A plain text summary of the article.                                                         |
| `extract_html`  | `String`  | An HTML-formatted summary of the article.                                                    |

---

## 2. `mostread` Object

This object contains a list of the most popular articles for a given day.

| Key        | Type            | Description                                                                                                |
| :--------- | :-------------- | :--------------------------------------------------------------------------------------------------------- |
| `date`     | `String`        | The date for which the view counts are reported (ISO 8601 format).                                         |
| `articles` | `Array<Object>` | An array of article objects, each with a structure similar to the `tfa` object but with additional fields. |

### `mostread.articles` Object Structure

Each object in the `articles` array includes the standard article fields (see `tfa` object) plus the following:

| Key            | Type            | Description                                                      |
| :------------- | :-------------- | :--------------------------------------------------------------- |
| `views`        | `Integer`       | The number of views for the specified `date`.                    |
| `rank`         | `Integer`       | The popularity rank of the article.                              |
| `view_history` | `Array<Object>` | An array containing daily view counts for the past several days. |

---

## 3. `image` (Image of the Day) Object

This object contains data about the featured image of the day from Wikimedia Commons.

| Key            | Type     | Description                                                           |
| :------------- | :------- | :-------------------------------------------------------------------- |
| `title`        | `String` | The file name of the image.                                           |
| `thumbnail`    | `Object` | Object with `source` URL and dimensions for a thumbnail.              |
| `image`        | `Object` | Object with `source` URL and dimensions for the full-size image.      |
| `file_page`    | `String` | URL to the image's description page on Wikimedia Commons.             |
| `artist`       | `Object` | Contains the `html` and `text` of the artist's name and profile link. |
| `credit`       | `Object` | Contains `html` and `text` for image attribution.                     |
| `license`      | `Object` | Contains the `type`, `code`, and `url` for the content license.       |
| `description`  | `Object` | Contains `html`, `text`, and `lang` for the image description.        |
| `wb_entity_id` | `String` | The WikiData entity ID for the media file.                            |
| `structured`   | `Object` | Contains structured data like `captions` in various languages.        |

---

## 4. `news` Array

This is an array of objects, where each object represents a single news story.

### News Item Object Structure

| Key     | Type            | Description                                                                                                           |
| :------ | :-------------- | :-------------------------------------------------------------------------------------------------------------------- |
| `links` | `Array<Object>` | An array of related Wikipedia article objects. Each object follows the structure described in the `tfa` section.      |
| `story` | `String`        | An HTML-formatted string summarizing the news event. It contains relative links to the articles in the `links` array. |

---

## 5. `onthisday` Array

This is an array of objects, where each object represents a significant historical event that occurred on this date.

### "On This Day" Event Object Structure

| Key     | Type            | Description                                                                                                      |
| :------ | :-------------- | :--------------------------------------------------------------------------------------------------------------- |
| `text`  | `String`        | A plain text description of the historical event.                                                                |
| `pages` | `Array<Object>` | An array of related Wikipedia article objects. Each object follows the structure described in the `tfa` section. |
| `year`  | `Integer`       | The year the event occurred.                                                                                     |
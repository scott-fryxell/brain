# Microdata Entities

Schema.org types for seeq-app entities and how to apply them.

## Entity types

| Entity | `itemtype` | Container element |
|---|---|---|
| Project | `https://schema.org/ResearchProject` | `<article>` |
| Story | `https://schema.org/Article` | `<article>` |
| Person / Author / Participant | `https://schema.org/Person` | `<article>` or `<address>` |
| Company / Sponsor / Organization | `https://schema.org/Organization` | `<article>` |
| Page / View | `https://schema.org/WebPage` | `<main>` |
| Site header | `https://schema.org/WPHeader` | `<header>` |
| Site nav | `https://schema.org/SiteNavigationElement` | `<nav>` |
| List of items | `https://schema.org/ItemList` | `<ul>` or `<ol>` |
| List item | `https://schema.org/ListItem` | `<li>` |

## Common itemprop values

### ResearchProject
```html
<article itemscope itemtype="https://schema.org/ResearchProject">
  <h2 itemprop="name">Project Name</h2>
  <p itemprop="description">...</p>
  <img itemprop="image" src="..." alt="..." loading="lazy">
  <a itemprop="url" href="/slug">link</a>
  <time itemprop="dateCreated" :datetime="project.created">{{ format_date(project.created) }}</time>
</article>
```

### Article (Story)
```html
<article itemscope itemtype="https://schema.org/Article">
  <h2 itemprop="headline">{{ story.title }}</h2>
  <p itemprop="articleBody">{{ story.content }}</p>
  <address itemprop="author" itemscope itemtype="https://schema.org/Person">
    <img itemprop="image" :src="story.author.avatar" alt="">
    <span itemprop="name">{{ story.author_name }}</span>
  </address>
  <time itemprop="datePublished" :datetime="story.created">{{ format_date(story.created) }}</time>
  <time itemprop="dateModified" :datetime="story.updated">{{ format_date(story.updated) }}</time>
  <span itemprop="wordCount"><data :value="word_count">{{ word_count }}</data></span>
</article>
```

### Person (Author / Participant)
```html
<article itemscope itemtype="https://schema.org/Person">
  <img itemprop="image" :src="person.avatar" :alt="person.name" loading="lazy">
  <h3 itemprop="name">{{ person.name }}</h3>
  <a itemprop="email" :href="`mailto:${person.email}`">{{ person.email }}</a>
</article>
```

### Organization (Sponsor / Company)
```html
<article itemscope itemtype="https://schema.org/Organization">
  <img itemprop="logo" :src="org.logo" :alt="org.name" loading="lazy">
  <span itemprop="name">{{ org.name }}</span>
  <a itemprop="url" :href="org.url">{{ org.url }}</a>
</article>
```

## Nesting entities

Nest entity scopes naturally inside parent scopes:

```html
<article itemscope itemtype="https://schema.org/ResearchProject">
  <h2 itemprop="name">{{ project.name }}</h2>

  <!-- Sponsor is a nested Organization inside a Project -->
  <section aria-label="Sponsors">
    <ul>
      <li v-for="sponsor in project.sponsors"
          itemscope itemprop="sponsor"
          itemtype="https://schema.org/Organization">
        <img itemprop="logo" :src="sponsor.logo" :alt="sponsor.name" loading="lazy">
        <span itemprop="name">{{ sponsor.name }}</span>
      </li>
    </ul>
  </section>
</article>
```

## Machine-readable values

When visible text differs from the machine-readable value, use these elements:

```html
<!-- Dates: always use datetime attribute -->
<time itemprop="datePublished" datetime="2024-03-15T10:30:00Z">March 15</time>

<!-- Numbers / IDs not shown as text -->
<meta itemprop="position" content="1">

<!-- Values where display format differs from data format -->
<data itemprop="wordCount" value="247">~250 words</data>
```

## ItemList pattern

For ordered or unordered lists of entities:

```html
<ul itemscope itemtype="https://schema.org/ItemList">
  <li v-for="(item, index) in items"
      itemprop="itemListElement"
      itemscope
      itemtype="https://schema.org/ListItem">
    <meta itemprop="position" :content="index + 1">
    <span itemprop="name">{{ item.name }}</span>
  </li>
</ul>
```

## Rules

- Add `itemscope itemtype` to the container element that wraps all data for that entity
- Add `itemprop` to child elements that carry a data field for the entity
- Do not add microdata to layout-only or structural-only elements
- When an entity is nested inside another, use `itemprop="sponsor"` / `itemprop="author"` on the nested `itemscope` element to link them
- `itemprop` can appear on any HTML element - the value source depends on the element type (`src` for `img`, `href` for `a`, `datetime` for `time`, `content` for `meta`, text content for everything else)

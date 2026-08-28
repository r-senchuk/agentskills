# JSON-LD Structured Data

## Reusable component

```typescript
// src/components/JsonLd.tsx
type JsonLdProps = {
  data: Record<string, unknown>;
};

export function JsonLd({ data }: JsonLdProps) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  );
}
```

## Schema builders

```typescript
// src/lib/structured-data.ts
export function buildLocalBusinessJsonLd(info: {
  name: string; description: string; url: string;
  phone: string; email: string;
  address: { street: string; city: string; region: string; postalCode: string; country: string };
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'LocalBusiness',
    name: info.name, description: info.description, url: info.url,
    telephone: info.phone, email: info.email,
    address: {
      '@type': 'PostalAddress',
      streetAddress: info.address.street,
      addressLocality: info.address.city,
      addressRegion: info.address.region,
      postalCode: info.address.postalCode,
      addressCountry: info.address.country,
    },
  };
}

export function buildWebSiteJsonLd(name: string, url: string) {
  return { '@context': 'https://schema.org', '@type': 'WebSite', name, url };
}
```

## Page usage

```typescript
import { JsonLd } from '@/components/JsonLd';
import { buildLocalBusinessJsonLd } from '@/lib/structured-data';

export default async function HomePage({ params }: Props) {
  const { locale } = await params;
  setRequestLocale(locale);

  const businessData = buildLocalBusinessJsonLd({
    name: 'Company Name',
    description: 'Company description',
    url: 'https://www.example.com',
    phone: '+1-555-0100',
    email: 'info@example.com',
    address: {
      street: '123 Main St',
      city: 'City',
      region: 'State',
      postalCode: '12345',
      country: 'US',
    },
  });

  return (
    <>
      <JsonLd data={businessData} />
      <main>{/* page content */}</main>
    </>
  );
}
```

Validate output at the Google Rich Results Test (see external-links.md).

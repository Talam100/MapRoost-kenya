# NyumbaLink Kenya

A mobile-friendly rental-house search website for Kenya. The public site is hosted by GitHub Pages and uses Supabase for shared listings.

## Live website

https://talam100.github.io/nyumbafinder-kenya/

## Shared listing system

- The Supabase project **NyumbaLink Kenya** contains the shared `public.listings` table.
- Visitors can submit listings. Submissions start with status `pending`.
- Visitors can read only listings whose status is `approved`.
- Visitors cannot approve, edit, or delete listings through the public website.
- Row Level Security is enabled. Public access is limited by SQL grants and policies.
- The browser uses the project's URL and publishable API key in `supabase-config.js`. Publishable keys are public; database passwords and secret/service-role keys must never be committed here.

## Reviewing new listings

1. Sign in at https://supabase.com/dashboard/.
2. Open the **NyumbaLink Kenya** project.
3. Open **Table Editor** and select `public.listings`.
4. Review each row with status `pending`. Check the details and contact the lister where needed.
5. Change status to `approved` to make the listing visible publicly. Change it to `rejected` to keep it hidden.

A listing marked approved has been approved by the website operator, but that does not automatically prove the property or landlord is genuine. Only describe a property as verified after actually checking it.

## Google indexing

Search-engine title, description, canonical URL, structured Website metadata, `robots.txt`, and `sitemap.xml` are in place.

To request indexing:
1. Open https://search.google.com/search-console/ and sign in to Google.
2. Add the URL-prefix property `https://talam100.github.io/nyumbafinder-kenya/`.
3. Complete the ownership verification flow Google offers.
4. Use **URL Inspection** on the homepage and request indexing.
5. Submit the sitemap URL `https://talam100.github.io/nyumbafinder-kenya/sitemap.xml` in the Sitemaps section when available.

Google controls whether and when pages are indexed; a request is not a guarantee and can take days or longer.

## Deployment

GitHub Actions publishes the site on every push to `main`. In the repository, **Settings → Pages** should use **GitHub Actions** as the deployment source.

## Current limits

- The listings table is newly created and starts empty. Only approved user-submitted listings appear once the site can load the database.
- The listing submission process is open to the public and currently has no user accounts, CAPTCHA, or automated spam controls. Monitor pending submissions regularly.
- Listing photos are supported as external image URLs; file upload storage has not been implemented.
- This starter version has no landlord login, self-service editing/deleting, or admin dashboard. Moderate entries through Supabase Table Editor.
- Favorites remain in the visitor's browser and are not synced between devices.
- The GitHub Pages address is free but still includes the old repository path. A custom domain is optional and normally costs money.
- Verify a property and landlord before paying any rent or deposit.

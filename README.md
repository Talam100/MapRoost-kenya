# NyumbaLink Kenya

A mobile-friendly Kenyan rental-house search website. The website is hosted free on GitHub Pages, and shared listings can be powered by a free Supabase project.

## Live website

https://talam100.github.io/nyumbafinder-kenya/

## What works now

- Mobile-friendly rental search by town, house type, and rent range.
- Demo properties are clearly marked and are not real rental offers.
- Search-engine title, description, canonical URL, structured website metadata, `robots.txt`, and `sitemap.xml`.
- Supabase integration code is prepared for shared listings.
- New shared submissions are designed to remain pending until manually reviewed.

## Step 1 — Create the free shared database

1. Create/sign in to a free account at https://supabase.com.
2. Create a project named `NyumbaLink Kenya`. Save the database password privately; do not put it in this GitHub repository.
3. Open **SQL Editor**, create a new query, paste the contents of `supabase-schema.sql`, and run it.
4. Open **Project Settings → API** (or the project's Connect/API section) and copy the **Project URL** and the **anon/public key**. Never use a `service_role` key in a browser website.

## Step 2 — Connect the website

1. Open `supabase-config.js` in this GitHub repository.
2. Replace the empty URL and anon key values with your project's Project URL and anon/public key.
3. Commit the change. GitHub Actions will publish the update automatically.
4. Open the live website and submit a test listing. It should say that the listing is awaiting review.

The URL and anon/public key are intended for browser use. The database Row Level Security rules are essential: public visitors can read only approved listings and can only submit new listings with a pending status.

## Step 3 — Review listings

In Supabase, open **Table Editor → listings**. Check each pending listing and contact information. Change `status` to `approved` to publish it, or `rejected` to keep it off the public site. Only approve listings after checking that the property and contact details are legitimate. Do not promise that any listing is verified unless you have actually verified it.

## Step 4 — Help Google find the site

1. Open https://search.google.com/search-console/ and sign in with your Google account.
2. Add the exact website URL as a URL-prefix property: `https://talam100.github.io/nyumbafinder-kenya/`.
3. Complete the ownership verification method Google offers. If the available verification method requires a file or tag, follow the exact instructions in Search Console.
4. In Search Console, use **URL Inspection** for the homepage and select **Request indexing**.
5. Submit `sitemap.xml` in the Sitemaps section if Search Console allows it for this property.

Google decides when and whether to index a page; submission is not a guarantee and may take days or longer. A custom domain is optional and would usually cost money, so this project keeps the existing free GitHub Pages address for now.

## Important limitations

- Until you configure the Supabase URL and anon/public key, submitted listings are saved only in the visitor's browser and are not shared.
- The free database provider has usage limits and may pause inactive free projects; check its current plan terms.
- Listings are user-submitted and not automatically verified. Visitors should view a property and verify the landlord before sending money.
- This starter version has no landlord accounts, photo upload service, automatic moderation, or admin dashboard. Review listings manually in Supabase.
- Keep database passwords and service-role secrets private. Never commit them to this repository.

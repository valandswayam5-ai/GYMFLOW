# GYMFLOW — Multi-Gym SaaS Starter

A black-and-white, responsive Next.js starter for a gym-management platform.

## Included demo screens
- Platform overview
- Platform admin / registered gyms
- Gym owner dashboard
- Member directory with local search
- Member portal preview
- Sign-in placeholder
- Supabase multi-tenant starter schema

## Run locally
Requirements: Node.js 20+ and npm.

```bash
npm install
cp .env.example .env.local
npm run dev
```

Open http://localhost:3000.

## GitHub + Vercel deployment
1. Create a new GitHub repository named `gymflow`.
2. Upload the contents of this folder to the repository root (not the ZIP file itself).
3. In Vercel, choose Add New → Project and import the GitHub repository.
4. Deploy. The demo UI does not require Supabase environment variables yet.
5. Add Supabase environment variables only after creating the project and connecting the backend.

## Supabase setup
1. Create a Supabase project.
2. Open SQL Editor.
3. Run `supabase/schema.sql`.
4. Configure authentication and invite/role assignment securely.
5. Add environment variables from `.env.example` in Vercel.

## Important honest status
This is a **starter/demo**, not a finished production SaaS. The screens use sample data. Add-member and add-gym buttons are visual placeholders; data is not saved. Authentication, member self-service, QR validation, payment gateway webhooks, PDF invoices, scheduled reminders, WhatsApp Business API, transactional email, and production-grade platform-admin permissions are not yet connected.

WhatsApp automated reminders require the official WhatsApp Business Platform or an authorized provider, business setup, approved templates where required, and may incur fees. Email delivery also needs a transactional email provider. Never store card details; verify payments through gateway webhooks or authorized manual reconciliation.

## Security before real customer data
- Complete and test tenant-isolation RLS policies.
- Add server-side role checks for every privileged operation.
- Add member self-access policies without exposing other members.
- Keep service-role keys and provider secrets server-side only.
- Review privacy, consent, retention, backups and audit logs.
- Test payment webhook signatures and idempotency.

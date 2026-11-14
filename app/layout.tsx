import "./globals.css";
import type { Metadata } from "next";
import { Sidebar } from "@/components/sidebar";

export const metadata: Metadata = {
  title: "GYMFLOW — Gym Management",
  description: "A modern operating system for gyms."
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="en"><body><div className="shell"><Sidebar /><main className="main">{children}</main></div></body></html>;
}

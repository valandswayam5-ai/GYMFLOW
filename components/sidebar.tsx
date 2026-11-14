"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
const links = [
  ["/", "Overview"], ["/dashboard", "Gym workspace"], ["/members", "Members"],
  ["/member", "Member portal"], ["/platform", "Platform admin"]
];
export function Sidebar() {
  const path = usePathname();
  return <aside className="sidebar">
    <Link href="/" className="brand"><span className="brandmark">G</span><span>GYMFLOW<small>GYM OPERATING SYSTEM</small></span></Link>
    <div className="side-label">WORKSPACE</div>
    <nav>{links.map(([href,label]) => <Link key={href} href={href} className={`navlink ${path===href ? "active" : ""}`}><span className="navdot" />{label}</Link>)}</nav>
    <div className="side-bottom"><div className="avatar">GF</div><div><b>Demo workspace</b><small>Starter environment</small></div></div>
  </aside>;
}

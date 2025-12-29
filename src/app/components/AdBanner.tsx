import { Info } from "lucide-react";

interface AdBannerProps {
  position?: "top" | "bottom";
}

export function AdBanner({ position = "bottom" }: AdBannerProps) {
  return (
    <div className={`w-full bg-muted/50 border-t border-border ${position === "top" ? "border-b" : ""}`}>
      <div className="p-3 text-center">
        <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground font-medium">
          <Info className="w-3.5 h-3.5" />
          <span>AdMob Banner Ad</span>
        </div>
        <div className="mt-1 text-[10px] text-muted-foreground/70 font-medium">
          320x50 Banner Placement
        </div>
      </div>
    </div>
  );
}
import { ReactNode } from "react";

interface MobileContainerProps {
  children: ReactNode;
}

export function MobileContainer({ children }: MobileContainerProps) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 flex items-center justify-center p-0 lg:p-6">
      {/* Mobile Frame */}
      <div className="relative w-full h-[100dvh] lg:max-w-[430px] lg:h-[932px] bg-white lg:rounded-[3rem] overflow-hidden lg:shadow-2xl">
        {/* Notch (iOS style) - Only on desktop */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-40 h-7 bg-gray-900 rounded-b-3xl z-50 hidden lg:block" />
        
        {/* Status Bar */}
        <div className="absolute top-0 left-0 right-0 h-11 bg-transparent z-40 flex items-center justify-between px-6 lg:px-8 text-xs font-medium">
          <span className="text-foreground font-semibold">9:41</span>
          <div className="flex items-center gap-1.5 text-foreground">
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12.01 21.49L23.64 7c-.45-.34-4.93-4-11.64-4C5.28 3 .81 6.66.36 7l11.63 14.49.01.01.01-.01z"/>
            </svg>
            <svg className="w-3 h-3" viewBox="0 0 16 16" fill="currentColor">
              <path d="M11.5 1A3.5 3.5 0 0 0 8 4.5V7H2.5A1.5 1.5 0 0 0 1 8.5v6A1.5 1.5 0 0 0 2.5 16h11a1.5 1.5 0 0 0 1.5-1.5v-6A1.5 1.5 0 0 0 13.5 7H13V4.5A3.5 3.5 0 0 0 9.5 1h-2zm2 6V4.5a2 2 0 0 0-2-2h-2a2 2 0 0 0-2 2V7h6z"/>
            </svg>
            <span className="text-foreground font-semibold">100%</span>
          </div>
        </div>
        
        {/* Content */}
        <div className="relative w-full h-full pt-11">
          {children}
        </div>

        {/* Home Indicator (iOS style) - Only on desktop */}
        <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-32 h-1 bg-gray-900 rounded-full z-50 hidden lg:block" />
      </div>
    </div>
  );
}
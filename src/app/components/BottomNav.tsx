import { Home, Calendar, Plus, User } from "lucide-react";

interface BottomNavProps {
  activeTab: "home" | "calendar" | "profile";
  onTabChange: (tab: "home" | "calendar" | "profile") => void;
  onAddClick: () => void;
}

type Tab = "home" | "calendar" | "profile";

export function BottomNav({ activeTab, onTabChange, onAddClick }: BottomNavProps) {
  const tabs = [
    { id: "home" as const, label: "Home", icon: Home },
    { id: "calendar" as const, label: "Calendar", icon: Calendar },
    { id: "profile" as const, label: "Profile", icon: User },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-card border-t border-border z-30 shadow-lg safe-area-bottom">
      <div className="px-2 sm:px-4 py-1.5 sm:py-2 flex items-center justify-around max-w-[430px] mx-auto">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => tab.id !== "add" && onTabChange(tab.id as Tab)}
            className={`flex flex-col items-center justify-center py-1.5 sm:py-2 px-3 sm:px-4 rounded-xl transition-all min-w-0 ${
              activeTab === tab.id
                ? "text-primary"
                : "text-muted-foreground hover:text-foreground active:text-foreground"
            }`}
          >
            <tab.icon className={`w-5 h-5 sm:w-6 sm:h-6 ${activeTab === tab.id ? "scale-110" : ""} transition-transform`} />
            <span className={`text-[10px] sm:text-xs mt-0.5 sm:mt-1 font-semibold ${activeTab === tab.id ? "" : "font-medium"} truncate w-full text-center`}>
              {tab.label}
            </span>
          </button>
        ))}

        {/* FAB Add Button */}
        <button
          onClick={onAddClick}
          className="absolute -top-5 sm:-top-6 left-1/2 -translate-x-1/2 w-12 h-12 sm:w-14 sm:h-14 bg-gradient-to-br from-primary to-secondary text-white rounded-2xl shadow-lg flex items-center justify-center hover:shadow-xl active:shadow-xl transition-all hover:scale-105 active:scale-95"
        >
          <Plus className="w-5 h-5 sm:w-6 sm:h-6" />
        </button>
      </div>
    </div>
  );
}
import { motion } from "motion/react";
import {
  User,
  Mail,
  Settings,
  Bell,
  Shield,
  LogOut,
  ChevronRight,
  Edit,
  Moon,
  Sun,
} from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar";
import { Button } from "./ui/button";
import { Switch } from "./ui/switch";
import { useState } from "react";

interface ProfileScreenProps {
  onLogout: () => void;
  onSettings: () => void;
}

export function ProfileScreen({ onLogout, onSettings }: ProfileScreenProps) {
  const [darkMode, setDarkMode] = useState(false);
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);

  const user = {
    name: "Alex Johnson",
    email: "alex.johnson@example.com",
    photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Alex",
    birthdaysCount: 15,
    upcomingCount: 3,
  };

  return (
    <div className="h-full bg-background overflow-hidden flex flex-col">
      {/* Header */}
      <div className="bg-card border-b border-border">
        <div className="px-4 sm:px-5 py-4 sm:py-5">
          <h2 className="text-foreground text-xl sm:text-2xl font-semibold">Profile</h2>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto px-4 sm:px-5 py-4 sm:py-6 pb-20 sm:pb-24 space-y-4">
        {/* Profile Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-card rounded-xl sm:rounded-2xl shadow-sm border border-border p-4 sm:p-6"
        >
          <div className="flex items-center gap-3 sm:gap-4 mb-4 sm:mb-6">
            <Avatar className="w-16 h-16 sm:w-20 sm:h-20 border-2 border-primary/20 shadow-sm">
              <AvatarImage src={user.photo} alt={user.name} />
              <AvatarFallback className="bg-primary/10 text-primary text-lg sm:text-xl font-semibold">
                {user.name.split(" ").map((n) => n[0]).join("")}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 min-w-0">
              <h3 className="text-foreground font-semibold text-base sm:text-lg">{user.name}</h3>
              <p className="text-muted-foreground flex items-center gap-1.5 sm:gap-2 mt-1 text-xs sm:text-sm truncate">
                <Mail className="w-3.5 h-3.5 sm:w-4 sm:h-4 flex-shrink-0" />
                <span className="truncate">{user.email}</span>
              </p>
            </div>
            <button className="w-9 h-9 sm:w-10 sm:h-10 rounded-full hover:bg-muted active:bg-muted flex items-center justify-center transition-colors flex-shrink-0">
              <Edit className="w-4 h-4 sm:w-5 sm:h-5 text-muted-foreground" />
            </button>
          </div>

          <div className="grid grid-cols-2 gap-3 sm:gap-4">
            <div className="bg-primary/5 rounded-xl p-3 sm:p-4 text-center">
              <div className="text-primary text-xl sm:text-2xl font-bold">{user.birthdaysCount}</div>
              <div className="text-[10px] sm:text-xs text-muted-foreground mt-1 font-medium">Total Birthdays</div>
            </div>
            <div className="bg-secondary/5 rounded-xl p-3 sm:p-4 text-center">
              <div className="text-secondary text-xl sm:text-2xl font-bold">{user.upcomingCount}</div>
              <div className="text-[10px] sm:text-xs text-muted-foreground mt-1 font-medium">This Month</div>
            </div>
          </div>
        </motion.div>

        {/* Quick Settings */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-card rounded-xl sm:rounded-2xl shadow-sm border border-border overflow-hidden"
        >
          <div className="px-4 sm:px-6 py-3 sm:py-4 border-b border-border">
            <h4 className="text-foreground font-semibold text-sm sm:text-base">Quick Settings</h4>
          </div>

          <div className="divide-y divide-border">
            <div className="px-4 sm:px-6 py-3 sm:py-4 flex items-center justify-between">
              <div className="flex items-center gap-2.5 sm:gap-3 min-w-0 flex-1">
                <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                  <Bell className="w-4 h-4 sm:w-5 sm:h-5 text-primary" />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="text-xs sm:text-sm text-foreground font-medium truncate">Notifications</div>
                  <div className="text-[10px] sm:text-xs text-muted-foreground truncate">
                    Birthday reminders
                  </div>
                </div>
              </div>
              <Switch
                checked={notificationsEnabled}
                onCheckedChange={setNotificationsEnabled}
              />
            </div>

            <div className="px-4 sm:px-6 py-3 sm:py-4 flex items-center justify-between">
              <div className="flex items-center gap-2.5 sm:gap-3 min-w-0 flex-1">
                <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-secondary/10 flex items-center justify-center flex-shrink-0">
                  {darkMode ? (
                    <Moon className="w-4 h-4 sm:w-5 sm:h-5 text-secondary" />
                  ) : (
                    <Sun className="w-4 h-4 sm:w-5 sm:h-5 text-secondary" />
                  )}
                </div>
                <div className="min-w-0 flex-1">
                  <div className="text-xs sm:text-sm text-foreground font-medium truncate">Dark Mode</div>
                  <div className="text-[10px] sm:text-xs text-muted-foreground truncate">
                    Change theme appearance
                  </div>
                </div>
              </div>
              <Switch checked={darkMode} onCheckedChange={setDarkMode} />
            </div>
          </div>
        </motion.div>

        {/* Menu Items */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="bg-card rounded-xl sm:rounded-2xl shadow-sm border border-border overflow-hidden"
        >
          <button
            onClick={onSettings}
            className="w-full px-4 sm:px-6 py-3 sm:py-4 flex items-center justify-between hover:bg-muted active:bg-muted transition-colors"
          >
            <div className="flex items-center gap-2.5 sm:gap-3 min-w-0 flex-1">
              <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-muted flex items-center justify-center flex-shrink-0">
                <Settings className="w-4 h-4 sm:w-5 sm:h-5 text-muted-foreground" />
              </div>
              <div className="text-left min-w-0 flex-1">
                <div className="text-xs sm:text-sm text-foreground font-medium truncate">App Settings</div>
                <div className="text-[10px] sm:text-xs text-muted-foreground truncate">
                  Preferences & more
                </div>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 sm:w-5 sm:h-5 text-muted-foreground flex-shrink-0" />
          </button>

          <div className="border-t border-border" />

          <button className="w-full px-4 sm:px-6 py-3 sm:py-4 flex items-center justify-between hover:bg-muted active:bg-muted transition-colors">
            <div className="flex items-center gap-2.5 sm:gap-3 min-w-0 flex-1">
              <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-muted flex items-center justify-center flex-shrink-0">
                <Shield className="w-4 h-4 sm:w-5 sm:h-5 text-muted-foreground" />
              </div>
              <div className="text-left min-w-0 flex-1">
                <div className="text-xs sm:text-sm text-foreground font-medium truncate">Privacy & Security</div>
                <div className="text-[10px] sm:text-xs text-muted-foreground truncate">
                  Manage your data
                </div>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 sm:w-5 sm:h-5 text-muted-foreground flex-shrink-0" />
          </button>
        </motion.div>

        {/* Logout */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <Button
            onClick={onLogout}
            variant="outline"
            className="w-full text-destructive hover:text-destructive hover:bg-destructive/10 h-11 sm:h-12 text-sm sm:text-base font-semibold"
          >
            <LogOut className="w-4 h-4 mr-2" />
            Sign Out
          </Button>
        </motion.div>

        {/* App Info */}
        <div className="text-center text-[10px] sm:text-xs text-muted-foreground pt-2 sm:pt-4 pb-2">
          <p className="font-medium">BirthdayBuddy v1.0.0</p>
          <div className="flex items-center justify-center gap-3 sm:gap-4 mt-2">
            <button className="hover:text-foreground transition-colors">
              Privacy Policy
            </button>
            <span>•</span>
            <button className="hover:text-foreground transition-colors">
              Terms of Service
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
import { useState, useEffect } from "react";
import { MobileContainer } from "./components/MobileContainer";
import { SplashScreen } from "./components/SplashScreen";
import { AuthScreen } from "./components/AuthScreen";
import { ContactSyncScreen } from "./components/ContactSyncScreen";
import { ContactSyncProgress } from "./components/ContactSyncProgress";
import { HomeScreen } from "./components/HomeScreen";
import { BirthdayDetail } from "./components/BirthdayDetail";
import { BirthdayForm } from "./components/BirthdayForm";
import { ProfileScreen } from "./components/ProfileScreen";
import { SettingsScreen } from "./components/SettingsScreen";
import { BottomNav } from "./components/BottomNav";
import { InterstitialAd } from "./components/InterstitialAd";
import { Birthday } from "./types";

type Screen = "splash" | "auth" | "contactSync" | "contactSyncProgress" | "main";
type ModalScreen = "detail" | "add" | "edit" | "settings" | null;
type Tab = "home" | "calendar" | "profile";

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>("splash");
  const [modalScreen, setModalScreen] = useState<ModalScreen>(null);
  const [activeTab, setActiveTab] = useState<Tab>("home");
  const [selectedBirthday, setSelectedBirthday] = useState<Birthday | null>(null);
  const [showInterstitialAd, setShowInterstitialAd] = useState(false);

  // Mock birthday data
  const [birthdays, setBirthdays] = useState<Birthday[]>([]);

  // Initialize mock data
  useEffect(() => {
    const mockBirthdays = generateMockBirthdays();
    setBirthdays(mockBirthdays);
  }, []);

  function generateMockBirthdays(): Birthday[] {
    const today = new Date();
    const mockData = [
      { name: "Sarah Johnson", month: 11, day: 28, year: 1995, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah" },
      { name: "Michael Chen", month: 11, day: 30, year: 1988, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Michael" },
      { name: "Emma Williams", month: 0, day: 5, year: 1992, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Emma" },
      { name: "David Martinez", month: 0, day: 15, year: 1990, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=David" },
      { name: "Sophie Anderson", month: 1, day: 14, year: 1993, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Sophie" },
      { name: "James Wilson", month: 2, day: 20, year: 1985, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=James" },
      { name: "Olivia Brown", month: 3, day: 10, year: 1996, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Olivia" },
      { name: "Ethan Davis", month: 4, day: 25, year: 1991, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Ethan" },
      { name: "Ava Garcia", month: 5, day: 8, year: 1994, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Ava" },
      { name: "Noah Miller", month: 6, day: 17, year: 1989, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Noah" },
      { name: "Isabella Taylor", month: 7, day: 22, year: 1997, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Isabella" },
      { name: "Lucas Moore", month: 8, day: 12, year: 1987, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Lucas" },
      { name: "Mia Jackson", month: 9, day: 5, year: 1995, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Mia" },
      { name: "Alexander White", month: 10, day: 18, year: 1992, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Alexander" },
      { name: "Charlotte Harris", month: 11, day: 27, year: 1990, photo: "https://api.dicebear.com/7.x/avataaars/svg?seed=Charlotte" },
    ];

    return mockData.map((person, index) => {
      const birthdate = new Date(person.year, person.month, person.day);
      const nextBirthday = new Date(today.getFullYear(), person.month, person.day);
      
      if (nextBirthday < today) {
        nextBirthday.setFullYear(today.getFullYear() + 1);
      }

      const daysUntil = Math.ceil((nextBirthday.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
      const age = today.getFullYear() - person.year - (nextBirthday > today ? 0 : 0);

      return {
        id: `birthday-${index}`,
        name: person.name,
        birthdate: `${person.year}-${String(person.month + 1).padStart(2, "0")}-${String(person.day).padStart(2, "0")}`,
        age: age,
        daysUntil: daysUntil,
        photo: person.photo,
        reminderEnabled: true,
        reminderDays: daysUntil <= 7 ? 1 : 3,
      };
    });
  }

  const handleSplashComplete = () => {
    setCurrentScreen("auth");
  };

  const handleLogin = () => {
    setCurrentScreen("contactSync");
  };

  const handleContactSyncEnable = () => {
    setCurrentScreen("contactSyncProgress");
  };

  const handleContactSyncSkip = () => {
    setCurrentScreen("main");
  };

  const handleContactSyncComplete = () => {
    setCurrentScreen("main");
  };

  const handleLogout = () => {
    setCurrentScreen("auth");
    setActiveTab("home");
  };

  const handleAddBirthday = () => {
    setSelectedBirthday(null);
    setModalScreen("add");
  };

  const handleBirthdayClick = (birthday: Birthday) => {
    setSelectedBirthday(birthday);
    setModalScreen("detail");
  };

  const handleEditBirthday = (birthday: Birthday) => {
    setSelectedBirthday(birthday);
    setModalScreen("edit");
  };

  const handleDeleteBirthday = (id: string) => {
    setBirthdays(birthdays.filter((b) => b.id !== id));
    setModalScreen(null);
  };

  const handleSaveBirthday = (birthdayData: Omit<Birthday, "id" | "daysUntil">) => {
    if (selectedBirthday) {
      // Edit existing
      const today = new Date();
      const birthdate = new Date(birthdayData.birthdate);
      const nextBirthday = new Date(today.getFullYear(), birthdate.getMonth(), birthdate.getDate());
      if (nextBirthday < today) {
        nextBirthday.setFullYear(today.getFullYear() + 1);
      }
      const daysUntil = Math.ceil((nextBirthday.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

      setBirthdays(
        birthdays.map((b) =>
          b.id === selectedBirthday.id
            ? { ...birthdayData, id: b.id, daysUntil }
            : b
        )
      );
    } else {
      // Add new
      const today = new Date();
      const birthdate = new Date(birthdayData.birthdate);
      const nextBirthday = new Date(today.getFullYear(), birthdate.getMonth(), birthdate.getDate());
      if (nextBirthday < today) {
        nextBirthday.setFullYear(today.getFullYear() + 1);
      }
      const daysUntil = Math.ceil((nextBirthday.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

      const newBirthday: Birthday = {
        ...birthdayData,
        id: `birthday-${Date.now()}`,
        daysUntil,
      };
      setBirthdays([...birthdays, newBirthday]);

      // Show interstitial ad after adding birthday
      setShowInterstitialAd(true);
    }
    
    setModalScreen(null);
    setSelectedBirthday(null);
  };

  const handleToggleReminder = () => {
    if (selectedBirthday) {
      setBirthdays(
        birthdays.map((b) =>
          b.id === selectedBirthday.id
            ? { ...b, reminderEnabled: !b.reminderEnabled }
            : b
        )
      );
      setSelectedBirthday({
        ...selectedBirthday,
        reminderEnabled: !selectedBirthday.reminderEnabled,
      });
    }
  };

  // Splash Screen
  if (currentScreen === "splash") {
    return (
      <MobileContainer>
        <SplashScreen onComplete={handleSplashComplete} />
      </MobileContainer>
    );
  }

  // Auth Screen
  if (currentScreen === "auth") {
    return (
      <MobileContainer>
        <AuthScreen onLogin={handleLogin} />
      </MobileContainer>
    );
  }

  // Contact Sync Screen
  if (currentScreen === "contactSync") {
    return (
      <MobileContainer>
        <ContactSyncScreen
          onEnable={handleContactSyncEnable}
          onSkip={handleContactSyncSkip}
        />
      </MobileContainer>
    );
  }

  // Contact Sync Progress Screen
  if (currentScreen === "contactSyncProgress") {
    return (
      <MobileContainer>
        <ContactSyncProgress onComplete={handleContactSyncComplete} />
      </MobileContainer>
    );
  }

  // Main App
  return (
    <MobileContainer>
      <div className="relative h-full">
        {/* Modal Screens */}
        {modalScreen === "detail" && selectedBirthday && (
          <div className="absolute inset-0 z-50 bg-background">
            <BirthdayDetail
              birthday={selectedBirthday}
              onBack={() => setModalScreen(null)}
              onEdit={() => handleEditBirthday(selectedBirthday)}
              onDelete={() => handleDeleteBirthday(selectedBirthday.id)}
              onToggleReminder={handleToggleReminder}
            />
          </div>
        )}

        {(modalScreen === "add" || modalScreen === "edit") && (
          <div className="absolute inset-0 z-50 bg-background">
            <BirthdayForm
              birthday={selectedBirthday || undefined}
              onSave={handleSaveBirthday}
              onCancel={() => {
                setModalScreen(null);
                setSelectedBirthday(null);
              }}
            />
          </div>
        )}

        {modalScreen === "settings" && (
          <div className="absolute inset-0 z-50 bg-background">
            <SettingsScreen onBack={() => setModalScreen(null)} />
          </div>
        )}

        {/* Main Content */}
        <div className={modalScreen ? "hidden" : "h-full"}>
          {activeTab === "home" && (
            <HomeScreen
              birthdays={birthdays}
              onAddBirthday={handleAddBirthday}
              onBirthdayClick={handleBirthdayClick}
              onEditBirthday={handleEditBirthday}
              onDeleteBirthday={handleDeleteBirthday}
            />
          )}

          {activeTab === "calendar" && (
            <HomeScreen
              birthdays={birthdays}
              onAddBirthday={handleAddBirthday}
              onBirthdayClick={handleBirthdayClick}
              onEditBirthday={handleEditBirthday}
              onDeleteBirthday={handleDeleteBirthday}
            />
          )}

          {activeTab === "profile" && (
            <ProfileScreen
              onLogout={handleLogout}
              onSettings={() => setModalScreen("settings")}
            />
          )}

          {/* Bottom Navigation */}
          <BottomNav
            activeTab={activeTab}
            onTabChange={setActiveTab}
            onAddClick={handleAddBirthday}
          />
        </div>

        {/* Interstitial Ad */}
        {showInterstitialAd && (
          <InterstitialAd onClose={() => setShowInterstitialAd(false)} />
        )}
      </div>
    </MobileContainer>
  );
}
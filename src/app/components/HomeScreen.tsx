import { useState } from "react";
import { motion } from "motion/react";
import { Calendar, List, Plus, Search } from "lucide-react";
import { BirthdayCard } from "./BirthdayCard";
import { CalendarView } from "./CalendarView";
import { AdBanner } from "./AdBanner";
import { Input } from "./ui/input";
import { Button } from "./ui/button";
import { Birthday } from "../types";

interface HomeScreenProps {
  birthdays: Birthday[];
  onAddBirthday: () => void;
  onBirthdayClick: (birthday: Birthday) => void;
  onEditBirthday: (birthday: Birthday) => void;
  onDeleteBirthday: (id: string) => void;
}

export function HomeScreen({
  birthdays,
  onAddBirthday,
  onBirthdayClick,
  onEditBirthday,
  onDeleteBirthday,
}: HomeScreenProps) {
  const [viewMode, setViewMode] = useState<"list" | "calendar">("list");
  const [searchQuery, setSearchQuery] = useState("");

  const filteredBirthdays = birthdays.filter((birthday) =>
    birthday.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const upcomingBirthdays = filteredBirthdays
    .filter((b) => b.daysUntil >= 0)
    .sort((a, b) => a.daysUntil - b.daysUntil);

  return (
    <div className="h-full flex flex-col bg-background overflow-hidden">
      {/* Header */}
      <div className="bg-card border-b border-border sticky top-0 z-10 shadow-sm">
        <div className="px-4 sm:px-5 py-4 sm:py-5">
          <h1 className="text-foreground mb-3 sm:mb-4 text-xl sm:text-2xl font-semibold">Upcoming Birthdays</h1>
          
          {/* Search Bar */}
          <div className="relative mb-3 sm:mb-4">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 sm:w-5 sm:h-5 text-muted-foreground pointer-events-none" />
            <Input
              type="text"
              placeholder="Search birthdays..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-9 sm:pl-10 h-10 sm:h-11 border-border bg-muted/50 focus:bg-background rounded-xl text-sm sm:text-base"
            />
          </div>

          {/* View Toggle */}
          <div className="flex gap-2 bg-muted p-1 rounded-xl">
            <button
              onClick={() => setViewMode("list")}
              className={`flex-1 py-2 sm:py-2.5 px-3 sm:px-4 rounded-lg transition-all font-semibold text-xs sm:text-sm ${
                viewMode === "list"
                  ? "bg-white text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <List className="w-3.5 h-3.5 sm:w-4 sm:h-4 inline mr-1.5 sm:mr-2" />
              List
            </button>
            <button
              onClick={() => setViewMode("calendar")}
              className={`flex-1 py-2 sm:py-2.5 px-3 sm:px-4 rounded-lg transition-all font-semibold text-xs sm:text-sm ${
                viewMode === "calendar"
                  ? "bg-white text-foreground shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <Calendar className="w-3.5 h-3.5 sm:w-4 sm:h-4 inline mr-1.5 sm:mr-2" />
              Calendar
            </button>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto pb-20 sm:pb-24">
        <div className="px-4 sm:px-5 py-4 sm:py-6">
          {viewMode === "list" ? (
            <>
              {upcomingBirthdays.length === 0 ? (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="text-center py-16"
                >
                  <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <Calendar className="w-10 h-10 text-gray-400" />
                  </div>
                  <h3 className="text-gray-900 mb-2">No Birthdays Found</h3>
                  <p className="text-muted-foreground mb-6">
                    {searchQuery
                      ? "Try adjusting your search"
                      : "Add your first birthday to get started"}
                  </p>
                  {!searchQuery && (
                    <Button onClick={onAddBirthday} className="bg-primary hover:bg-primary/90">
                      <Plus className="w-4 h-4 mr-2" />
                      Add Birthday
                    </Button>
                  )}
                </motion.div>
              ) : (
                <div className="space-y-3">
                  {upcomingBirthdays.map((birthday, index) => (
                    <motion.div
                      key={birthday.id}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.05 }}
                    >
                      <BirthdayCard
                        birthday={birthday}
                        onClick={() => onBirthdayClick(birthday)}
                        onEdit={() => onEditBirthday(birthday)}
                        onDelete={() => onDeleteBirthday(birthday.id)}
                      />
                    </motion.div>
                  ))}
                </div>
              )}
            </>
          ) : (
            <CalendarView
              birthdays={filteredBirthdays}
              onBirthdayClick={onBirthdayClick}
            />
          )}
        </div>
      </div>

      {/* FAB */}
      <motion.button
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.9 }}
        onClick={onAddBirthday}
        className="fixed bottom-20 right-6 w-14 h-14 bg-primary text-white rounded-full shadow-lg flex items-center justify-center z-20 hover:shadow-xl transition-shadow"
      >
        <Plus className="w-6 h-6" />
      </motion.button>

      {/* Ad Banner */}
      <div className="fixed bottom-0 left-0 right-0 z-10">
        <AdBanner />
      </div>
    </div>
  );
}
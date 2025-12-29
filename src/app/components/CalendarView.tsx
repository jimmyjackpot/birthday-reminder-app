import { useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { Birthday } from "../types";
import { motion } from "motion/react";

interface CalendarViewProps {
  birthdays: Birthday[];
  onBirthdayClick: (birthday: Birthday) => void;
}

export function CalendarView({ birthdays, onBirthdayClick }: CalendarViewProps) {
  const [currentDate, setCurrentDate] = useState(new Date());

  const monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  const daysInMonth = new Date(
    currentDate.getFullYear(),
    currentDate.getMonth() + 1,
    0
  ).getDate();

  const firstDayOfMonth = new Date(
    currentDate.getFullYear(),
    currentDate.getMonth(),
    1
  ).getDay();

  const prevMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1));
  };

  const nextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1));
  };

  const getBirthdaysForDate = (day: number) => {
    return birthdays.filter((birthday) => {
      const birthDate = new Date(birthday.birthdate);
      return (
        birthDate.getDate() === day &&
        birthDate.getMonth() === currentDate.getMonth()
      );
    });
  };

  const days = [];
  
  // Empty cells for days before month starts
  for (let i = 0; i < firstDayOfMonth; i++) {
    days.push(<div key={`empty-${i}`} className="aspect-square" />);
  }

  // Days of the month
  for (let day = 1; day <= daysInMonth; day++) {
    const dayBirthdays = getBirthdaysForDate(day);
    const isToday =
      day === new Date().getDate() &&
      currentDate.getMonth() === new Date().getMonth() &&
      currentDate.getFullYear() === new Date().getFullYear();

    days.push(
      <motion.div
        key={day}
        whileHover={{ scale: dayBirthdays.length > 0 ? 1.05 : 1 }}
        className={`aspect-square p-1 rounded-lg relative ${
          isToday ? "bg-primary/10 ring-2 ring-primary/30" : ""
        } ${dayBirthdays.length > 0 ? "cursor-pointer" : ""}`}
        onClick={() => {
          if (dayBirthdays.length === 1) {
            onBirthdayClick(dayBirthdays[0]);
          }
        }}
      >
        <div
          className={`text-sm ${
            isToday ? "text-primary" : "text-gray-700"
          } text-center`}
        >
          {day}
        </div>
        {dayBirthdays.length > 0 && (
          <div className="absolute bottom-1 left-1/2 -translate-x-1/2 flex gap-0.5">
            {dayBirthdays.slice(0, 3).map((birthday) => (
              <div
                key={birthday.id}
                className="w-1.5 h-1.5 rounded-full bg-primary"
                title={birthday.name}
              />
            ))}
          </div>
        )}
      </motion.div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-4">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <button
          onClick={prevMonth}
          className="w-8 h-8 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
        >
          <ChevronLeft className="w-5 h-5" />
        </button>
        <h3 className="text-gray-900">
          {monthNames[currentDate.getMonth()]} {currentDate.getFullYear()}
        </h3>
        <button
          onClick={nextMonth}
          className="w-8 h-8 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
        >
          <ChevronRight className="w-5 h-5" />
        </button>
      </div>

      {/* Weekday labels */}
      <div className="grid grid-cols-7 gap-1 mb-2">
        {["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((day) => (
          <div key={day} className="text-xs text-center text-muted-foreground py-2">
            {day}
          </div>
        ))}
      </div>

      {/* Calendar grid */}
      <div className="grid grid-cols-7 gap-1">{days}</div>

      {/* Legend */}
      <div className="mt-4 pt-4 border-t border-gray-100">
        <div className="flex items-center gap-2 text-xs text-muted-foreground">
          <div className="w-2 h-2 rounded-full bg-primary" />
          <span>Has birthday</span>
          <div className="w-6 h-6 rounded bg-primary/10 ring-1 ring-primary/30 ml-4" />
          <span>Today</span>
        </div>
      </div>

      {/* Birthdays this month */}
      {birthdays.filter((b) => {
        const birthDate = new Date(b.birthdate);
        return birthDate.getMonth() === currentDate.getMonth();
      }).length > 0 && (
        <div className="mt-4 pt-4 border-t border-gray-100">
          <h4 className="text-gray-900 mb-3">This Month</h4>
          <div className="space-y-2">
            {birthdays
              .filter((b) => {
                const birthDate = new Date(b.birthdate);
                return birthDate.getMonth() === currentDate.getMonth();
              })
              .sort((a, b) => {
                const dateA = new Date(a.birthdate).getDate();
                const dateB = new Date(b.birthdate).getDate();
                return dateA - dateB;
              })
              .map((birthday) => (
                <div
                  key={birthday.id}
                  onClick={() => onBirthdayClick(birthday)}
                  className="flex items-center gap-3 p-2 rounded-lg hover:bg-gray-50 cursor-pointer transition-colors"
                >
                  <div className="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center text-sm">
                    {new Date(birthday.birthdate).getDate()}
                  </div>
                  <div className="flex-1">
                    <div className="text-sm text-gray-900">{birthday.name}</div>
                    <div className="text-xs text-muted-foreground">
                      Turns {birthday.age}
                    </div>
                  </div>
                </div>
              ))}
          </div>
        </div>
      )}
    </div>
  );
}

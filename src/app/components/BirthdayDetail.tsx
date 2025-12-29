import { motion } from "motion/react";
import {
  ArrowLeft,
  Cake,
  Calendar,
  Gift,
  MessageCircle,
  Share2,
  Bell,
  BellOff,
  Edit,
  Trash2,
} from "lucide-react";
import { Birthday } from "../types";
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar";
import { Button } from "./ui/button";
import { useState } from "react";
import { WishDialog } from "./WishDialog";

interface BirthdayDetailProps {
  birthday: Birthday;
  onBack: () => void;
  onEdit: () => void;
  onDelete: () => void;
  onToggleReminder: () => void;
}

export function BirthdayDetail({
  birthday,
  onBack,
  onEdit,
  onDelete,
  onToggleReminder,
}: BirthdayDetailProps) {
  const [showWishDialog, setShowWishDialog] = useState(false);

  const formattedDate = new Date(birthday.birthdate).toLocaleDateString("en-US", {
    month: "long",
    day: "numeric",
    year: "numeric",
  });

  const getDaysText = () => {
    if (birthday.daysUntil === 0) return "Birthday is today! 🎉";
    if (birthday.daysUntil === 1) return "Birthday is tomorrow!";
    return `${birthday.daysUntil} days until birthday`;
  };

  return (
    <>
      <div className="min-h-screen bg-gradient-to-br from-primary/10 via-secondary/10 to-accent/10">
        {/* Header with Back Button */}
        <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
          <div className="px-4 py-4 flex items-center justify-between">
            <button
              onClick={onBack}
              className="w-10 h-10 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
            >
              <ArrowLeft className="w-5 h-5" />
            </button>
            <h2 className="text-gray-900">Birthday Details</h2>
            <div className="w-10" />
          </div>
        </div>

        {/* Content */}
        <div className="px-4 py-6 pb-24">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white rounded-2xl shadow-lg overflow-hidden"
          >
            {/* Hero Section */}
            <div className="relative h-32 bg-gradient-to-br from-primary via-secondary to-accent">
              <div className="absolute inset-0 flex items-center justify-center">
                <Cake className="w-16 h-16 text-white/30" />
              </div>
            </div>

            {/* Profile */}
            <div className="relative px-6 pb-6">
              <div className="flex flex-col items-center -mt-16">
                <Avatar className="w-24 h-24 border-4 border-white shadow-lg">
                  <AvatarImage src={birthday.photo} alt={birthday.name} />
                  <AvatarFallback className="bg-primary/10 text-primary text-xl">
                    {birthday.name.split(" ").map((n) => n[0]).join("").slice(0, 2)}
                  </AvatarFallback>
                </Avatar>

                <h1 className="text-gray-900 mt-4">{birthday.name}</h1>
                <p className="text-muted-foreground mt-1">{getDaysText()}</p>
              </div>

              {/* Info Cards */}
              <div className="grid grid-cols-3 gap-3 mt-6">
                <div className="bg-primary/5 rounded-xl p-4 text-center">
                  <Calendar className="w-6 h-6 text-primary mx-auto mb-2" />
                  <div className="text-xs text-muted-foreground">Birthday</div>
                  <div className="text-sm text-gray-900 mt-1">
                    {new Date(birthday.birthdate).toLocaleDateString("en-US", {
                      month: "short",
                      day: "numeric",
                    })}
                  </div>
                </div>

                <div className="bg-secondary/5 rounded-xl p-4 text-center">
                  <Cake className="w-6 h-6 text-secondary mx-auto mb-2" />
                  <div className="text-xs text-muted-foreground">Age</div>
                  <div className="text-sm text-gray-900 mt-1">
                    {birthday.age} years
                  </div>
                </div>

                <div className="bg-accent/20 rounded-xl p-4 text-center">
                  <Gift className="w-6 h-6 text-accent-foreground mx-auto mb-2" />
                  <div className="text-xs text-muted-foreground">Days Left</div>
                  <div className="text-sm text-gray-900 mt-1">
                    {birthday.daysUntil}
                  </div>
                </div>
              </div>

              {/* Details */}
              <div className="mt-6 space-y-3">
                <div className="flex items-center justify-between py-3 border-b border-gray-100">
                  <div>
                    <div className="text-sm text-gray-900">Full Birthdate</div>
                    <div className="text-xs text-muted-foreground mt-1">
                      {formattedDate}
                    </div>
                  </div>
                </div>

                <div className="flex items-center justify-between py-3 border-b border-gray-100">
                  <div>
                    <div className="text-sm text-gray-900">Reminder</div>
                    <div className="text-xs text-muted-foreground mt-1">
                      {birthday.reminderEnabled
                        ? `${birthday.reminderDays} days before`
                        : "Disabled"}
                    </div>
                  </div>
                  <button
                    onClick={onToggleReminder}
                    className={`w-12 h-12 rounded-full flex items-center justify-center transition-colors ${
                      birthday.reminderEnabled
                        ? "bg-primary/10 text-primary"
                        : "bg-gray-100 text-gray-400"
                    }`}
                  >
                    {birthday.reminderEnabled ? (
                      <Bell className="w-5 h-5" />
                    ) : (
                      <BellOff className="w-5 h-5" />
                    )}
                  </button>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="mt-6 space-y-3">
                <Button
                  onClick={() => setShowWishDialog(true)}
                  className="w-full bg-primary hover:bg-primary/90"
                >
                  <MessageCircle className="w-4 h-4 mr-2" />
                  Send Birthday Wish
                </Button>

                <div className="grid grid-cols-2 gap-3">
                  <Button variant="outline" className="w-full">
                    <Share2 className="w-4 h-4 mr-2" />
                    Share
                  </Button>
                  <Button variant="outline" onClick={onEdit} className="w-full">
                    <Edit className="w-4 h-4 mr-2" />
                    Edit
                  </Button>
                </div>

                <Button
                  variant="outline"
                  onClick={onDelete}
                  className="w-full text-destructive hover:text-destructive"
                >
                  <Trash2 className="w-4 h-4 mr-2" />
                  Delete Birthday
                </Button>
              </div>
            </div>
          </motion.div>
        </div>
      </div>

      {showWishDialog && (
        <WishDialog
          birthday={birthday}
          onClose={() => setShowWishDialog(false)}
        />
      )}
    </>
  );
}
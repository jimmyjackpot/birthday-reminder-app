import { useState, useEffect } from "react";
import { motion } from "motion/react";
import { Users, Check } from "lucide-react";
import { Button } from "./ui/button";

interface ContactSyncProgressProps {
  onComplete: () => void;
}

export function ContactSyncProgress({ onComplete }: ContactSyncProgressProps) {
  const [progress, setProgress] = useState(0);
  const [contactsFound, setContactsFound] = useState(0);
  const [birthdaysImported, setBirthdaysImported] = useState(0);
  const [completed, setCompleted] = useState(false);

  useEffect(() => {
    const timer = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          clearInterval(timer);
          setCompleted(true);
          return 100;
        }
        return prev + 2;
      });
    }, 50);

    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    setContactsFound(Math.floor((progress / 100) * 156));
    setBirthdaysImported(Math.floor((progress / 100) * 42));
  }, [progress]);

  return (
    <div className="h-full bg-gradient-to-b from-background to-muted flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md my-auto"
      >
        {/* Icon */}
        <div className="flex justify-center mb-6 sm:mb-8">
          <motion.div
            animate={completed ? { scale: [1, 1.1, 1] } : { rotate: 360 }}
            transition={
              completed
                ? { duration: 0.5 }
                : { duration: 2, repeat: Infinity, ease: "linear" }
            }
            className={`w-20 h-20 sm:w-24 sm:h-24 rounded-3xl flex items-center justify-center shadow-xl ${
              completed
                ? "bg-gradient-to-br from-green-500 to-green-600"
                : "bg-gradient-to-br from-primary to-secondary"
            }`}
          >
            {completed ? (
              <Check className="w-10 h-10 sm:w-12 sm:h-12 text-white" />
            ) : (
              <Users className="w-10 h-10 sm:w-12 sm:h-12 text-white" />
            )}
          </motion.div>
        </div>

        {/* Title */}
        <div className="text-center mb-6 sm:mb-8">
          <h1 className="text-foreground mb-2 sm:mb-3 text-xl sm:text-2xl font-semibold">
            {completed ? "Sync Complete!" : "Syncing Contacts..."}
          </h1>
          <p className="text-muted-foreground text-sm sm:text-base px-2">
            {completed
              ? "Successfully imported birthdays from your contacts"
              : "Please wait while we import your contacts"}
          </p>
        </div>

        {/* Progress Card */}
        <div className="bg-card rounded-xl sm:rounded-2xl p-5 sm:p-6 mb-5 sm:mb-6 shadow-lg border border-border">
          {/* Progress Bar */}
          <div className="mb-5 sm:mb-6">
            <div className="flex justify-between mb-2">
              <span className="text-xs sm:text-sm font-medium text-foreground">Progress</span>
              <span className="text-xs sm:text-sm font-semibold text-primary">{progress}%</span>
            </div>
            <div className="h-2 bg-muted rounded-full overflow-hidden">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                className="h-full bg-gradient-to-r from-primary to-secondary"
              />
            </div>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-2 gap-3 sm:gap-4">
            <div className="bg-muted rounded-xl p-3 sm:p-4 text-center">
              <div className="text-xl sm:text-2xl font-bold text-foreground mb-1">
                {contactsFound}
              </div>
              <div className="text-[10px] sm:text-xs text-muted-foreground font-medium">Contacts Scanned</div>
            </div>
            <div className="bg-muted rounded-xl p-3 sm:p-4 text-center">
              <div className="text-xl sm:text-2xl font-bold text-primary mb-1">
                {birthdaysImported}
              </div>
              <div className="text-[10px] sm:text-xs text-muted-foreground font-medium">Birthdays Found</div>
            </div>
          </div>
        </div>

        {/* Action */}
        {completed && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <Button
              onClick={onComplete}
              className="w-full bg-gradient-to-r from-primary to-secondary hover:opacity-90 text-white h-11 sm:h-12 rounded-xl font-semibold shadow-lg text-sm sm:text-base"
            >
              Continue to App
            </Button>
          </motion.div>
        )}

        {!completed && (
          <div className="text-center">
            <p className="text-[10px] sm:text-xs text-muted-foreground">
              This may take a few moments...
            </p>
          </div>
        )}
      </motion.div>
    </div>
  );
}
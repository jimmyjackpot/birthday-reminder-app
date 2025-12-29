import { motion } from "motion/react";
import { Users, Check, X, Download, AlertCircle } from "lucide-react";
import { Button } from "./ui/button";

interface ContactSyncScreenProps {
  onEnable: () => void;
  onSkip: () => void;
}

export function ContactSyncScreen({ onEnable, onSkip }: ContactSyncScreenProps) {
  return (
    <div className="h-full bg-gradient-to-b from-background to-muted flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md my-auto"
      >
        {/* Icon */}
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ type: "spring", delay: 0.2 }}
          className="flex justify-center mb-6 sm:mb-8"
        >
          <div className="w-20 h-20 sm:w-24 sm:h-24 bg-gradient-to-br from-primary to-secondary rounded-3xl flex items-center justify-center shadow-xl">
            <Users className="w-10 h-10 sm:w-12 sm:h-12 text-white" />
          </div>
        </motion.div>

        {/* Title */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.3 }}
          className="text-center mb-6 sm:mb-8"
        >
          <h1 className="text-foreground mb-2 sm:mb-3 text-xl sm:text-2xl font-semibold">Sync Your Contacts</h1>
          <p className="text-muted-foreground text-sm sm:text-base px-2">
            Import birthdays from your device contacts to never miss a celebration
          </p>
        </motion.div>

        {/* Features */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="bg-card rounded-xl sm:rounded-2xl p-4 sm:p-6 mb-5 sm:mb-6 shadow-lg border border-border"
        >
          <div className="space-y-3 sm:space-y-4">
            <div className="flex items-start gap-2.5 sm:gap-3">
              <div className="w-9 h-9 sm:w-10 sm:h-10 bg-primary/10 rounded-full flex items-center justify-center flex-shrink-0">
                <Check className="w-4 h-4 sm:w-5 sm:h-5 text-primary" />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="text-foreground font-semibold mb-0.5 sm:mb-1 text-sm sm:text-base">Automatic Import</h3>
                <p className="text-muted-foreground text-xs sm:text-sm">
                  Instantly import birthdays from contact list
                </p>
              </div>
            </div>

            <div className="flex items-start gap-2.5 sm:gap-3">
              <div className="w-9 h-9 sm:w-10 sm:h-10 bg-secondary/10 rounded-full flex items-center justify-center flex-shrink-0">
                <Download className="w-4 h-4 sm:w-5 sm:h-5 text-secondary" />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="text-foreground font-semibold mb-0.5 sm:mb-1 text-sm sm:text-base">Stay Updated</h3>
                <p className="text-muted-foreground text-xs sm:text-sm">
                  Sync automatically when contacts change
                </p>
              </div>
            </div>

            <div className="flex items-start gap-2.5 sm:gap-3">
              <div className="w-9 h-9 sm:w-10 sm:h-10 bg-accent/10 rounded-full flex items-center justify-center flex-shrink-0">
                <AlertCircle className="w-4 h-4 sm:w-5 sm:h-5 text-accent" />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="text-foreground font-semibold mb-0.5 sm:mb-1 text-sm sm:text-base">Privacy First</h3>
                <p className="text-muted-foreground text-xs sm:text-sm">
                  Only birthday information is accessed
                </p>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Actions */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="space-y-3"
        >
          <Button
            onClick={onEnable}
            className="w-full bg-gradient-to-r from-primary to-secondary hover:opacity-90 text-white h-11 sm:h-12 rounded-xl font-semibold shadow-lg text-sm sm:text-base"
          >
            Enable Contact Sync
          </Button>
          <Button
            onClick={onSkip}
            variant="ghost"
            className="w-full h-11 sm:h-12 rounded-xl font-medium text-muted-foreground hover:text-foreground text-sm sm:text-base"
          >
            Skip for Now
          </Button>
        </motion.div>

        {/* Privacy Note */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6 }}
          className="text-center text-[10px] sm:text-xs text-muted-foreground mt-4 sm:mt-6 px-4"
        >
          You can enable or disable this feature anytime in settings
        </motion.p>
      </motion.div>
    </div>
  );
}
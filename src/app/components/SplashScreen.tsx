import { motion } from "motion/react";
import { Cake, Sparkles } from "lucide-react";
import { useEffect } from "react";

interface SplashScreenProps {
  onComplete: () => void;
}

export function SplashScreen({ onComplete }: SplashScreenProps) {
  useEffect(() => {
    const timer = setTimeout(() => {
      onComplete();
    }, 2500);

    return () => clearTimeout(timer);
  }, [onComplete]);

  return (
    <motion.div
      initial={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-gradient-to-br from-primary via-secondary to-accent flex items-center justify-center px-4"
    >
      <div className="text-center">
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ type: "spring", duration: 0.8, delay: 0.2 }}
          className="relative inline-block mb-4 sm:mb-6"
        >
          <div className="w-20 h-20 sm:w-24 sm:h-24 bg-white rounded-full flex items-center justify-center shadow-2xl">
            <Cake className="w-10 h-10 sm:w-12 sm:h-12 text-primary" />
          </div>
          <motion.div
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.6 }}
            className="absolute -top-1 sm:-top-2 -right-1 sm:-right-2"
          >
            <Sparkles className="w-6 h-6 sm:w-8 sm:h-8 text-accent fill-accent" />
          </motion.div>
        </motion.div>
        
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          className="text-white mb-2 text-2xl sm:text-3xl font-bold"
        >
          BirthdayBuddy
        </motion.h1>
        
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.2 }}
          className="text-white/90 text-sm sm:text-base"
        >
          Never Miss a Special Day
        </motion.p>

        <motion.button
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.5 }}
          onClick={onComplete}
          className="mt-6 sm:mt-8 px-5 sm:px-6 py-2 sm:py-2.5 bg-white/20 backdrop-blur-sm border border-white/30 text-white rounded-full hover:bg-white/30 active:bg-white/30 transition-all text-sm sm:text-base font-medium"
        >
          Skip
        </motion.button>
      </div>
    </motion.div>
  );
}
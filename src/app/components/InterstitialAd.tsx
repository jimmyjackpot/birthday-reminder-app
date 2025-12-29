import { X } from "lucide-react";
import { motion } from "motion/react";

interface InterstitialAdProps {
  onClose: () => void;
}

export function InterstitialAd({ onClose }: InterstitialAdProps) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center"
      onClick={onClose}
    >
      <motion.div
        initial={{ scale: 0.9 }}
        animate={{ scale: 1 }}
        className="bg-white rounded-xl p-8 max-w-sm mx-4 relative"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          onClick={onClose}
          className="absolute top-2 right-2 w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center hover:bg-gray-300 transition-colors"
        >
          <X className="w-4 h-4" />
        </button>
        
        <div className="text-center">
          <div className="mb-4 text-gray-500">
            <span className="text-xs">AdMob Interstitial Ad</span>
          </div>
          <div className="w-full h-48 bg-gradient-to-br from-blue-100 to-purple-100 rounded-lg flex items-center justify-center">
            <div className="text-center">
              <div className="text-sm text-gray-600 mb-2">Advertisement</div>
              <div className="text-xs text-gray-400">300x250</div>
            </div>
          </div>
          <button
            onClick={onClose}
            className="mt-6 px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors"
          >
            Continue
          </button>
        </div>
      </motion.div>
    </motion.div>
  );
}

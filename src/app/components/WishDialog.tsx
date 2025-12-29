import { useState } from "react";
import { motion } from "motion/react";
import { X, MessageCircle, Send } from "lucide-react";
import { Birthday } from "../types";
import { Button } from "./ui/button";
import { Textarea } from "./ui/textarea";

interface WishDialogProps {
  birthday: Birthday;
  onClose: () => void;
}

const wishTemplates = [
  "🎉 Happy Birthday! Wishing you a day filled with love and laughter!",
  "🎂 Another year older, another year wiser! Have an amazing birthday!",
  "🎈 May all your wishes come true on this special day! Happy Birthday!",
  "🎁 Sending you smiles for every moment of your special day!",
  "🌟 Hope your birthday is as special as you are!",
];

export function WishDialog({ birthday, onClose }: WishDialogProps) {
  const [selectedTemplate, setSelectedTemplate] = useState(wishTemplates[0]);
  const [customMessage, setCustomMessage] = useState(wishTemplates[0]);
  const [showCustom, setShowCustom] = useState(false);

  const handleShare = (platform: string) => {
    console.log(`Sharing to ${platform}:`, customMessage);
    onClose();
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center"
      onClick={onClose}
    >
      <motion.div
        initial={{ y: "100%" }}
        animate={{ y: 0 }}
        exit={{ y: "100%" }}
        className="bg-white rounded-t-2xl sm:rounded-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
          <h3 className="text-gray-900">Send Birthday Wish</h3>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Recipient */}
          <div className="flex items-center gap-3 p-3 bg-primary/5 rounded-lg">
            <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center text-primary">
              {birthday.name.split(" ").map((n) => n[0]).join("").slice(0, 2)}
            </div>
            <div>
              <div className="text-sm text-gray-900">{birthday.name}</div>
              <div className="text-xs text-muted-foreground">
                Birthday: {new Date(birthday.birthdate).toLocaleDateString("en-US", {
                  month: "long",
                  day: "numeric",
                })}
              </div>
            </div>
          </div>

          {/* Templates */}
          {!showCustom && (
            <div className="space-y-3">
              <label className="text-sm text-gray-900">Choose a message template</label>
              <div className="space-y-2">
                {wishTemplates.map((template, index) => (
                  <button
                    key={index}
                    onClick={() => {
                      setSelectedTemplate(template);
                      setCustomMessage(template);
                    }}
                    className={`w-full text-left p-3 rounded-lg border-2 transition-all ${
                      selectedTemplate === template
                        ? "border-primary bg-primary/5"
                        : "border-gray-200 hover:border-gray-300"
                    }`}
                  >
                    <p className="text-sm text-gray-700">{template}</p>
                  </button>
                ))}
              </div>

              <Button
                variant="outline"
                onClick={() => setShowCustom(true)}
                className="w-full"
              >
                <MessageCircle className="w-4 h-4 mr-2" />
                Write Custom Message
              </Button>
            </div>
          )}

          {/* Custom Message */}
          {showCustom && (
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <label className="text-sm text-gray-900">Your custom message</label>
                <button
                  onClick={() => setShowCustom(false)}
                  className="text-xs text-primary hover:underline"
                >
                  Use Template
                </button>
              </div>
              <Textarea
                value={customMessage}
                onChange={(e) => setCustomMessage(e.target.value)}
                rows={5}
                placeholder="Write your birthday wish..."
                className="resize-none"
              />
            </div>
          )}

          {/* Share Options */}
          <div className="space-y-3">
            <label className="text-sm text-gray-900">Share via</label>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => handleShare("WhatsApp")}
                className="flex items-center justify-center gap-2 p-4 border-2 border-gray-200 rounded-lg hover:border-green-500 hover:bg-green-50 transition-all"
              >
                <div className="w-6 h-6 rounded-full bg-green-500 flex items-center justify-center">
                  <MessageCircle className="w-4 h-4 text-white" />
                </div>
                <span className="text-sm">WhatsApp</span>
              </button>

              <button
                onClick={() => handleShare("Messages")}
                className="flex items-center justify-center gap-2 p-4 border-2 border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-all"
              >
                <div className="w-6 h-6 rounded-full bg-blue-500 flex items-center justify-center">
                  <Send className="w-4 h-4 text-white" />
                </div>
                <span className="text-sm">SMS</span>
              </button>

              <button
                onClick={() => handleShare("Email")}
                className="flex items-center justify-center gap-2 p-4 border-2 border-gray-200 rounded-lg hover:border-red-500 hover:bg-red-50 transition-all"
              >
                <div className="w-6 h-6 rounded-full bg-red-500 flex items-center justify-center">
                  <span className="text-xs text-white">@</span>
                </div>
                <span className="text-sm">Email</span>
              </button>

              <button
                onClick={() => handleShare("Messenger")}
                className="flex items-center justify-center gap-2 p-4 border-2 border-gray-200 rounded-lg hover:border-purple-500 hover:bg-purple-50 transition-all"
              >
                <div className="w-6 h-6 rounded-full bg-purple-500 flex items-center justify-center">
                  <MessageCircle className="w-4 h-4 text-white" />
                </div>
                <span className="text-sm">Messenger</span>
              </button>
            </div>
          </div>
        </div>
      </motion.div>
    </motion.div>
  );
}

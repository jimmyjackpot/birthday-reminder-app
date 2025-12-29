import { motion } from "motion/react";
import { ArrowLeft, Bell, Volume2, Globe, Info, Heart, Users, Download } from "lucide-react";
import { Switch } from "./ui/switch";
import { useState } from "react";

interface SettingsScreenProps {
  onBack: () => void;
}

export function SettingsScreen({ onBack }: SettingsScreenProps) {
  const [settings, setSettings] = useState({
    pushNotifications: true,
    emailNotifications: false,
    soundEnabled: true,
    vibrationEnabled: true,
    weekStartsOnMonday: false,
    autoSync: true,
    adFrequency: "normal" as "low" | "normal" | "high",
    contactSyncEnabled: false,
  });

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary/5 via-secondary/5 to-accent/5">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="px-4 py-4 flex items-center gap-4">
          <button
            onClick={onBack}
            className="w-10 h-10 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h2 className="text-gray-900">Settings</h2>
        </div>
      </div>

      {/* Content */}
      <div className="px-4 py-6 pb-24 space-y-4">
        {/* Contact Sync Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden"
        >
          <div className="p-4 border-b border-gray-100">
            <h3 className="text-gray-900 flex items-center gap-2">
              <Users className="w-5 h-5 text-primary" />
              Contact Sync
            </h3>
          </div>
          <div className="p-4 space-y-3">
            <div className="flex items-center justify-between">
              <div className="flex-1">
                <h4 className="text-sm font-medium text-gray-900">Enable Contact Sync</h4>
                <p className="text-xs text-muted-foreground mt-1">
                  Automatically import birthdays from your contacts
                </p>
              </div>
              <Switch
                checked={settings.contactSyncEnabled}
                onCheckedChange={(checked) =>
                  setSettings({ ...settings, contactSyncEnabled: checked })
                }
              />
            </div>
            {settings.contactSyncEnabled && (
              <>
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <h4 className="text-sm font-medium text-gray-900">Auto Sync</h4>
                    <p className="text-xs text-muted-foreground mt-1">
                      Sync contacts automatically when changed
                    </p>
                  </div>
                  <Switch
                    checked={settings.autoSync}
                    onCheckedChange={(checked) =>
                      setSettings({ ...settings, autoSync: checked })
                    }
                  />
                </div>
                <div className="pt-2">
                  <button className="w-full py-2.5 px-4 bg-primary/10 text-primary rounded-xl text-sm font-semibold hover:bg-primary/20 transition-colors flex items-center justify-center gap-2">
                    <Download className="w-4 h-4" />
                    Sync Now
                  </button>
                  <p className="text-xs text-muted-foreground mt-2 text-center">
                    Last synced: Today at 2:30 PM
                  </p>
                </div>
              </>
            )}
          </div>
        </motion.div>

        {/* Notifications Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white rounded-2xl shadow-sm overflow-hidden"
        >
          <div className="px-6 py-4 border-b border-gray-100 flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
              <Bell className="w-4 h-4 text-primary" />
            </div>
            <h4 className="text-gray-900">Notifications</h4>
          </div>

          <div className="divide-y divide-gray-100">
            <div className="px-6 py-4 flex items-center justify-between">
              <div>
                <div className="text-sm text-gray-900">Push Notifications</div>
                <div className="text-xs text-muted-foreground mt-1">
                  Receive birthday reminders
                </div>
              </div>
              <Switch
                checked={settings.pushNotifications}
                onCheckedChange={(checked) =>
                  setSettings({ ...settings, pushNotifications: checked })
                }
              />
            </div>

            <div className="px-6 py-4 flex items-center justify-between">
              <div>
                <div className="text-sm text-gray-900">Email Notifications</div>
                <div className="text-xs text-muted-foreground mt-1">
                  Get reminders via email
                </div>
              </div>
              <Switch
                checked={settings.emailNotifications}
                onCheckedChange={(checked) =>
                  setSettings({ ...settings, emailNotifications: checked })
                }
              />
            </div>
          </div>
        </motion.div>

        {/* Sound & Vibration */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-white rounded-2xl shadow-sm overflow-hidden"
        >
          <div className="px-6 py-4 border-b border-gray-100 flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-secondary/10 flex items-center justify-center">
              <Volume2 className="w-4 h-4 text-secondary" />
            </div>
            <h4 className="text-gray-900">Sound & Vibration</h4>
          </div>

          <div className="divide-y divide-gray-100">
            <div className="px-6 py-4 flex items-center justify-between">
              <div>
                <div className="text-sm text-gray-900">Sound</div>
                <div className="text-xs text-muted-foreground mt-1">
                  Play sound for notifications
                </div>
              </div>
              <Switch
                checked={settings.soundEnabled}
                onCheckedChange={(checked) =>
                  setSettings({ ...settings, soundEnabled: checked })
                }
              />
            </div>

            <div className="px-6 py-4 flex items-center justify-between">
              <div>
                <div className="text-sm text-gray-900">Vibration</div>
                <div className="text-xs text-muted-foreground mt-1">
                  Vibrate for reminders
                </div>
              </div>
              <Switch
                checked={settings.vibrationEnabled}
                onCheckedChange={(checked) =>
                  setSettings({ ...settings, vibrationEnabled: checked })
                }
              />
            </div>
          </div>
        </motion.div>

        {/* General */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="bg-white rounded-2xl shadow-sm overflow-hidden"
        >
          <div className="px-6 py-4 border-b border-gray-100 flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-accent/40 flex items-center justify-center">
              <Globe className="w-4 h-4 text-accent-foreground" />
            </div>
            <h4 className="text-gray-900">General</h4>
          </div>

          <div className="divide-y divide-gray-100">
            <div className="px-6 py-4 flex items-center justify-between">
              <div>
                <div className="text-sm text-gray-900">Week Starts On</div>
                <div className="text-xs text-muted-foreground mt-1">
                  Calendar week preference
                </div>
              </div>
              <select
                value={settings.weekStartsOnMonday ? "monday" : "sunday"}
                onChange={(e) =>
                  setSettings({
                    ...settings,
                    weekStartsOnMonday: e.target.value === "monday",
                  })
                }
                className="px-3 py-1.5 bg-gray-100 border-0 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-ring"
              >
                <option value="sunday">Sunday</option>
                <option value="monday">Monday</option>
              </select>
            </div>

            <div className="px-6 py-4 flex items-center justify-between">
              <div>
                <div className="text-sm text-gray-900">Auto Sync</div>
                <div className="text-xs text-muted-foreground mt-1">
                  Sync data automatically
                </div>
              </div>
              <Switch
                checked={settings.autoSync}
                onCheckedChange={(checked) =>
                  setSettings({ ...settings, autoSync: checked })
                }
              />
            </div>
          </div>
        </motion.div>

        {/* Ad Settings */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="bg-white rounded-2xl shadow-sm overflow-hidden"
        >
          <div className="px-6 py-4 border-b border-gray-100 flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-purple-100 flex items-center justify-center">
              <Info className="w-4 h-4 text-purple-600" />
            </div>
            <h4 className="text-gray-900">Advertisement</h4>
          </div>

          <div className="px-6 py-4">
            <div className="mb-2">
              <div className="text-sm text-gray-900 mb-1">Ad Frequency</div>
              <div className="text-xs text-muted-foreground mb-4">
                Control how often ads are displayed
              </div>
            </div>
            <div className="space-y-2">
              {(["low", "normal", "high"] as const).map((frequency) => (
                <button
                  key={frequency}
                  onClick={() => setSettings({ ...settings, adFrequency: frequency })}
                  className={`w-full text-left px-4 py-3 rounded-lg border-2 transition-all ${
                    settings.adFrequency === frequency
                      ? "border-primary bg-primary/5"
                      : "border-gray-200 hover:border-gray-300"
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className="text-sm capitalize">{frequency}</span>
                    {settings.adFrequency === frequency && (
                      <div className="w-5 h-5 rounded-full bg-primary flex items-center justify-center">
                        <div className="w-2 h-2 rounded-full bg-white" />
                      </div>
                    )}
                  </div>
                </button>
              ))}
            </div>
            <div className="mt-4 p-3 bg-blue-50 rounded-lg">
              <p className="text-xs text-blue-900">
                💡 Ads help keep BirthdayBuddy free for everyone
              </p>
            </div>
          </div>
        </motion.div>

        {/* Support */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="bg-gradient-to-r from-primary to-secondary rounded-2xl shadow-sm p-6 text-center text-white"
        >
          <Heart className="w-12 h-12 mx-auto mb-3 fill-white" />
          <h3 className="mb-2">Enjoying BirthdayBuddy?</h3>
          <p className="text-sm text-white/90 mb-4">
            Support us by upgrading to Premium for an ad-free experience!
          </p>
          <button className="bg-white text-primary px-6 py-2 rounded-lg hover:bg-white/90 transition-colors">
            Go Premium
          </button>
        </motion.div>
      </div>
    </div>
  );
}
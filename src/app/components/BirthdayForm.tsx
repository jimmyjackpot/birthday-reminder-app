import { useState, useEffect } from "react";
import { motion } from "motion/react";
import { ArrowLeft, Camera, Calendar, Bell } from "lucide-react";
import { Birthday } from "../types";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Switch } from "./ui/switch";
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar";

interface BirthdayFormProps {
  birthday?: Birthday;
  onSave: (birthday: Omit<Birthday, "id" | "daysUntil">) => void;
  onCancel: () => void;
}

export function BirthdayForm({ birthday, onSave, onCancel }: BirthdayFormProps) {
  const [formData, setFormData] = useState({
    name: birthday?.name || "",
    birthdate: birthday?.birthdate || "",
    photo: birthday?.photo || "",
    reminderEnabled: birthday?.reminderEnabled ?? true,
    reminderDays: birthday?.reminderDays || 1,
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const calculateAge = (birthdate: string) => {
    if (!birthdate) return 0;
    const birth = new Date(birthdate);
    const today = new Date();
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
      age--;
    }
    return age;
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.name.trim()) {
      newErrors.name = "Name is required";
    }

    if (!formData.birthdate) {
      newErrors.birthdate = "Birthdate is required";
    } else {
      const selectedDate = new Date(formData.birthdate);
      const today = new Date();
      if (selectedDate > today) {
        newErrors.birthdate = "Birthdate cannot be in the future";
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateForm()) {
      onSave({
        name: formData.name,
        birthdate: formData.birthdate,
        age: calculateAge(formData.birthdate),
        photo: formData.photo,
        reminderEnabled: formData.reminderEnabled,
        reminderDays: formData.reminderDays,
      });
    }
  };

  const handlePhotoUpload = () => {
    // Simulate photo upload - in real app would use file input
    const mockPhotos = [
      "https://api.dicebear.com/7.x/avataaars/svg?seed=Felix",
      "https://api.dicebear.com/7.x/avataaars/svg?seed=Aneka",
      "https://api.dicebear.com/7.x/avataaars/svg?seed=Luna",
    ];
    const randomPhoto = mockPhotos[Math.floor(Math.random() * mockPhotos.length)];
    setFormData({ ...formData, photo: randomPhoto });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary/5 via-secondary/5 to-accent/5">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="px-4 py-4 flex items-center justify-between">
          <button
            onClick={onCancel}
            className="w-10 h-10 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h2 className="text-gray-900">
            {birthday ? "Edit Birthday" : "Add Birthday"}
          </h2>
          <div className="w-10" />
        </div>
      </div>

      {/* Form */}
      <div className="px-4 py-6 pb-24">
        <motion.form
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          onSubmit={handleSubmit}
          className="bg-white rounded-2xl shadow-lg p-6 space-y-6"
        >
          {/* Photo Upload */}
          <div className="flex flex-col items-center">
            <Avatar className="w-24 h-24 border-4 border-primary/20">
              <AvatarImage src={formData.photo} alt={formData.name} />
              <AvatarFallback className="bg-primary/10 text-primary text-xl">
                {formData.name
                  ? formData.name.split(" ").map((n) => n[0]).join("").slice(0, 2)
                  : <Camera className="w-8 h-8" />}
              </AvatarFallback>
            </Avatar>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={handlePhotoUpload}
              className="mt-3"
            >
              <Camera className="w-4 h-4 mr-2" />
              {formData.photo ? "Change Photo" : "Add Photo"}
            </Button>
          </div>

          {/* Name */}
          <div className="space-y-2">
            <Label htmlFor="name">Full Name *</Label>
            <Input
              id="name"
              type="text"
              placeholder="Enter full name"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className={errors.name ? "border-destructive" : ""}
            />
            {errors.name && (
              <p className="text-xs text-destructive">{errors.name}</p>
            )}
          </div>

          {/* Birthdate */}
          <div className="space-y-2">
            <Label htmlFor="birthdate">Birth Date *</Label>
            <div className="relative">
              <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground pointer-events-none" />
              <Input
                id="birthdate"
                type="date"
                value={formData.birthdate}
                onChange={(e) => setFormData({ ...formData, birthdate: e.target.value })}
                className={`pl-10 ${errors.birthdate ? "border-destructive" : ""}`}
                max={new Date().toISOString().split("T")[0]}
              />
            </div>
            {errors.birthdate && (
              <p className="text-xs text-destructive">{errors.birthdate}</p>
            )}
            {formData.birthdate && !errors.birthdate && (
              <p className="text-xs text-muted-foreground">
                Age: {calculateAge(formData.birthdate)} years old
              </p>
            )}
          </div>

          {/* Reminder Settings */}
          <div className="space-y-4 pt-4 border-t border-gray-100">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                  <Bell className="w-5 h-5 text-primary" />
                </div>
                <div>
                  <Label htmlFor="reminder">Enable Reminder</Label>
                  <p className="text-xs text-muted-foreground">
                    Get notified before the birthday
                  </p>
                </div>
              </div>
              <Switch
                id="reminder"
                checked={formData.reminderEnabled}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, reminderEnabled: checked })
                }
              />
            </div>

            {formData.reminderEnabled && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                className="space-y-2"
              >
                <Label htmlFor="reminderDays">Remind me</Label>
                <select
                  id="reminderDays"
                  value={formData.reminderDays}
                  onChange={(e) =>
                    setFormData({ ...formData, reminderDays: Number(e.target.value) })
                  }
                  className="w-full px-3 py-2 bg-input-background border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-ring"
                >
                  <option value={1}>1 day before</option>
                  <option value={2}>2 days before</option>
                  <option value={3}>3 days before</option>
                  <option value={7}>1 week before</option>
                  <option value={14}>2 weeks before</option>
                </select>
              </motion.div>
            )}
          </div>

          {/* Actions */}
          <div className="flex gap-3 pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={onCancel}
              className="flex-1"
            >
              Cancel
            </Button>
            <Button type="submit" className="flex-1 bg-primary hover:bg-primary/90">
              {birthday ? "Save Changes" : "Add Birthday"}
            </Button>
          </div>
        </motion.form>
      </div>
    </div>
  );
}
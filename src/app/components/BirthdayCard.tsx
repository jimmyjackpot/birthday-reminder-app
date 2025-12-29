import { motion } from "motion/react";
import { Cake, Gift, MessageCircle, Share2, MoreVertical, Pencil, Trash2 } from "lucide-react";
import { Birthday } from "../types";
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "./ui/dropdown-menu";

interface BirthdayCardProps {
  birthday: Birthday;
  onClick: () => void;
  onEdit: () => void;
  onDelete: () => void;
}

export function BirthdayCard({ birthday, onClick, onEdit, onDelete }: BirthdayCardProps) {
  const getBirthdayStatus = (daysUntil: number) => {
    if (daysUntil === 0) return { text: "Today!", color: "text-primary" };
    if (daysUntil === 1) return { text: "Tomorrow", color: "text-secondary" };
    return { text: `In ${daysUntil} days`, color: "text-muted-foreground" };
  };

  const status = getBirthdayStatus(birthday.daysUntil);

  return (
    <motion.div
      whileHover={{ y: -2 }}
      whileTap={{ scale: 0.98 }}
      className="bg-card rounded-xl sm:rounded-2xl border border-border p-3 sm:p-4 cursor-pointer hover:shadow-lg transition-all shadow-sm active:shadow-md"
    >
      <div className="flex items-start gap-3 sm:gap-4">
        {/* Avatar */}
        <div onClick={onClick} className="flex-shrink-0">
          <Avatar className="w-12 h-12 sm:w-16 sm:h-16 border-2 border-primary/10 shadow-sm">
            <AvatarImage src={birthday.photo} alt={birthday.name} />
            <AvatarFallback className="bg-gradient-to-br from-primary/20 to-secondary/20 text-primary font-semibold text-sm sm:text-base">
              {birthday.name.split(" ").map((n) => n[0]).join("").slice(0, 2)}
            </AvatarFallback>
          </Avatar>
        </div>

        {/* Info */}
        <div onClick={onClick} className="flex-1 min-w-0">
          <h3 className="text-foreground font-semibold truncate text-sm sm:text-base">{birthday.name}</h3>
          <div className="flex items-center gap-2 sm:gap-3 mt-1 sm:mt-1.5">
            <div className="flex items-center gap-1 sm:gap-1.5 text-muted-foreground">
              <Cake className="w-3.5 h-3.5 sm:w-4 sm:h-4 flex-shrink-0" />
              <span className="text-xs sm:text-sm font-medium">Turns {birthday.age}</span>
            </div>
            <div className="flex items-center gap-1 sm:gap-1.5">
              <Gift className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-secondary flex-shrink-0" />
              <span className={`text-xs sm:text-sm font-semibold ${status.color}`}>{status.text}</span>
            </div>
          </div>
          <div className="text-[10px] sm:text-xs text-muted-foreground mt-1 sm:mt-1.5 font-medium">
            {new Date(birthday.birthdate).toLocaleDateString("en-US", {
              month: "long",
              day: "numeric",
            })}
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-0.5 sm:gap-1">
          <button
            onClick={(e) => {
              e.stopPropagation();
              // Share functionality
            }}
            className="w-8 h-8 sm:w-9 sm:h-9 rounded-full hover:bg-muted active:bg-muted flex items-center justify-center transition-colors"
          >
            <MessageCircle className="w-4 h-4 text-muted-foreground" />
          </button>
          
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button
                onClick={(e) => e.stopPropagation()}
                className="w-8 h-8 sm:w-9 sm:h-9 rounded-full hover:bg-muted active:bg-muted flex items-center justify-center transition-colors"
              >
                <MoreVertical className="w-4 h-4 text-muted-foreground" />
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={onEdit}>
                <Pencil className="w-4 h-4 mr-2" />
                Edit
              </DropdownMenuItem>
              <DropdownMenuItem onClick={onDelete} className="text-destructive">
                <Trash2 className="w-4 h-4 mr-2" />
                Delete
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Quick Action Pills */}
      {birthday.daysUntil <= 7 && (
        <div className="mt-3 sm:mt-4 flex gap-2">
          <button className="flex-1 py-2 sm:py-2.5 px-2 sm:px-3 bg-gradient-to-r from-primary/10 to-primary/5 text-primary rounded-lg sm:rounded-xl text-xs sm:text-sm font-semibold hover:from-primary/20 hover:to-primary/10 active:from-primary/20 active:to-primary/10 transition-all">
            <MessageCircle className="w-3 h-3 sm:w-3.5 sm:h-3.5 inline mr-1 sm:mr-1.5" />
            Wish
          </button>
          <button className="flex-1 py-2 sm:py-2.5 px-2 sm:px-3 bg-gradient-to-r from-secondary/10 to-secondary/5 text-secondary rounded-lg sm:rounded-xl text-xs sm:text-sm font-semibold hover:from-secondary/20 hover:to-secondary/10 active:from-secondary/20 active:to-secondary/10 transition-all">
            <Share2 className="w-3 h-3 sm:w-3.5 sm:h-3.5 inline mr-1 sm:mr-1.5" />
            Share
          </button>
        </div>
      )}
    </motion.div>
  );
}
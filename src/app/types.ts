export interface Birthday {
  id: string;
  name: string;
  birthdate: string; // YYYY-MM-DD format
  age: number;
  daysUntil: number;
  photo?: string;
  reminderEnabled: boolean;
  reminderDays: number;
}

export type Screen = 
  | "splash"
  | "auth"
  | "home"
  | "detail"
  | "add"
  | "edit"
  | "profile"
  | "settings";

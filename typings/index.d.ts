
import * as React from "react";
import {
  IOSNativeProps,
  AndroidNativeProps,
} from "@react-native-community/datetimepicker";

export interface MonthDayPickerProps {
  
  okButton?: string;
  cancelButton?: string;
  neutralButton?: string;

  
  /**
   * Initial selected date/time
   *
   * Default is a date object from `new Date()`
   */
  value: Date;

  /**
   * The date picker locale.
   */
  locale?: string;
 
  mode?: "full" | "short" | "number" | "shortNumber";

  autoTheme?: Boolean;
  theme?: "dark" | "light" 

  /**
   * Minimum date the picker can go back to
   */
  minimumDate?: Date;

  /**
   * Maximum date the picker can go forward to
   */
  maximumDate?: Date;

  

  /**
   * Date change handler.
   * This is called when the user changes the date or time in the UI.
   * The first and only argument is a Date object representing the new date and time.
   *
   * @extends from DatePickerIOSProperties
   */
  onChange?(newDate: Date): void;

  /**
   * Handler called when the user presses the confirm button
   * Passes the current selected date
   */
  onDone(date: Date): void;

  /**
   * Handler called when the user presses the cancel button
   * Passes the current selected date
   */
  onCancel(date: Date): void;

  /**
   * Called when the underlying modal finishes its' closing animation
   * after Confirm was pressed.
   */
  onNeutral?(date: Date): void;
}

export type ReactNativeModalMonthDayPickerProps = MonthDayPickerProps &
  Omit<IOSNativeProps, "value" | "mode"> &
  Omit<AndroidNativeProps, "value" | "mode">;

export default class MonthDayPicker extends React.Component<
ReactNativeModalMonthDayPickerProps,
  any
> {}

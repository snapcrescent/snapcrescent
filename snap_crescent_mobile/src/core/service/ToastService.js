import { ToastAndroid } from "react-native";

export function showToast(message, duration = ToastAndroid.SHORT) {
    ToastAndroid.showWithGravity(
        message,
        ToastAndroid.SHORT,
        ToastAndroid.CENTER
    );
}
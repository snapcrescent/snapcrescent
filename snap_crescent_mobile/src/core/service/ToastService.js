import { ToastAndroid } from "react-native";

export const showToast = (message, duration = ToastAndroid.SHORT) => {
    ToastAndroid.showWithGravity(
        message,
        duration,
        ToastAndroid.CENTER
    );
}

export const showErrorToast = (message, duration = ToastAndroid.SHORT) => {
    message = message ? message : 'Something went worng, Please try again.';
    ToastAndroid.showWithGravity(
        message,
        duration,
        ToastAndroid.CENTER
    );
}
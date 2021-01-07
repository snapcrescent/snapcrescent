import AsyncStorage from "@react-native-async-storage/async-storage";
import { isNotNull } from "../../utils/CoreUtil";

export function updateServerUrl(value) {
    if (isNotNull(value)) {
        try {
            AsyncStorage.setItem('serverUrl', value);
        } catch (error) {
            console.warn(error);
        }

        return {
            type: 'SERVER_URL_EXISTS',
            value
        }
    } else {
        try {
            AsyncStorage.removeItem('serverUrl');
        } catch (error) {
            console.warn(error);
        }

        return {
            type: 'SERVER_URL_DOES_NOT_EXISTS',
            value: ''
        }
    }
}


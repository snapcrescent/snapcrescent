import AsyncStorage from "@react-native-async-storage/async-storage";

export default function serverUrlReducer(state = null, action) {
    switch (action.type) {
        case 'SERVER_URL_EXISTS': {
            state = action.value;
            return state;
        }

        case 'SERVER_URL_DOES_NOT_EXISTS': {
            state = null;
            return state;
        }

        default:
            return state;
    }
}
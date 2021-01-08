import { isNotNull } from "../../utils/CoreUtil";

export function updateAuthState(value) {
    if (value == true) {
        return {
            type: 'AUTHENTICATED'
        };
    } else {
        return {
            type: 'NOT_AUTHENTICATED'
        };
    }
}

export function updateAuthToken(value) {
    if (isNotNull(value)) {
        return {
            type: "SET_AUTH_TOKEN",
            value
        };
    } else {
        return {
            type: "REMOVE_AUTH_TOKEN"
        };
    }
}
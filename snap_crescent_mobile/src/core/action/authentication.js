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
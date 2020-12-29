export const isNotNull = (value) => {
    if (value &&
        value != '' &&
        value.length > 0) {
        return true;
    }

    return false;
}
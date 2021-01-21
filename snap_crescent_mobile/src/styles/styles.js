import { StyleSheet } from "react-native";

export const THEME_COLORS = {
    primary: '#3f51bf',
    secondary: '#15c57e'
};

const CoreStyles = StyleSheet.create({
    flex1: {
        flex: 1
    },
    flex10: {
        flex: 10
    },
    leftAlignedContainer: {
        justifyContent: 'flex-start',
        alignItems: 'flex-start'
    },
    centerAlignedContainer: {
        justifyContent: 'center',
        alignItems: 'center'
    },
    rightAlignedContainer: {
        justifyContent: 'flex-end',
        alignItems: 'flex-end'
    },
    closeIcon: {
        fontSize: 24,
        color: '#ffffff'
    },
    width100: {
        width: "100%"
    }
});

export default CoreStyles;
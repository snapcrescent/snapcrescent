import React, { useState } from 'react';
import {
    FlatList,
    Modal,
    SafeAreaView,
    StatusBar,
    StyleSheet,
    Text,
    TouchableOpacity,
    View
} from 'react-native';
import FontAwesome5 from 'react-native-vector-icons/FontAwesome5';
import { signOut } from '../../../core/service/AuthService';
import ServerUrl from '../../user-authentication/ServerUrl';

const initialState = {
    showServerModal: false,
    showSignOutConfirmation: false
};

function Settings() {

    const [state, setState] = useState(initialState);

    const actions = [
        {
            label: 'Server Config',
            icon: 'server',
            onClick: () => { setState({ showSignOutConfirmation: false, showServerModal: true }) }
        },
        {
            label: 'Sign-Out',
            icon: 'sign-out-alt',
            onClick: () => { signOut(); }
        }
    ];

    const renderActions = ({ item }) => {
        return (
            <View style={styles.item}>
                <TouchableOpacity onPress={() => { item.onClick() }} style={styles.touchableContainer}>
                    <Text style={styles.label}>{item.label}</Text>
                    <FontAwesome5 name={item.icon} style={styles.itemIcon} />
                </TouchableOpacity>
            </View>
        )
    };

    return (
        <SafeAreaView style={styles.container}>
            <FlatList
                data={actions}
                renderItem={renderActions}
                keyExtractor={({ item, index }) => index}>
            </FlatList>

            <Modal transparent={true} visible={state.showServerModal}>
                <View style={{ flex: 1, backgroundColor: "#000000aa", padding: 25 }}>
                    <View style={{ flex: 1, backgroundColor: '#ffffff' }}>
                        <View style={styles.serverUrlContainer}>
                            <ServerUrl isModalLayout={true} onModalClose={() => { setState({ ...state, showServerModal: false }) }} />
                        </View>
                    </View>
                </View>
            </Modal>
        </SafeAreaView >
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        marginTop: StatusBar.currentHeight || 0,
    },
    item: {
        backgroundColor: '#ffffff',
        padding: 10,
        margin: 5
    },
    touchableContainer: {
        flex: 1,
        flexDirection: 'row',
        margin: 2
    },
    label: {
        fontSize: 20,
        flex: 10
    },
    itemIcon: {
        flex: 1,
        fontSize: 20,
    },
    serverUrlContainer: {
        flex: 1,
        justifyContent: 'center',
        alignContent: 'center'
    }
});

export default Settings;
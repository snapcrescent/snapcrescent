import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from "react-native";
import Menu, { MenuDivider, MenuItem } from "react-native-material-menu";
import { isNotNull } from "../../../utils/CoreUtil";
import FontAwesome5Icon from 'react-native-vector-icons/FontAwesome5';
import CoreStyles from '../../../styles/styles';

function DropMenu(props) {
    const { items, dropIcon, dropIconStyle, dropLabel, dropLabelStyle } = props;
    let menuRef = null;

    const menuTriggerButton = (
        <TouchableOpacity
            onPress={() => { menuRef?.show() }}
            style={{ paddingHorizontal: 5, marginHorizontal: 5 }}>
            {
                isNotNull(dropLabel)
                    ? <Text style={[styles.dropTrigger, dropLabelStyle]}>{dropLabel}</Text>
                    : <FontAwesome5Icon
                        name={dropIcon ? dropIcon : 'ellipsis-v'}
                        style={[styles.dropTrigger, dropIconStyle]} />
            }
        </TouchableOpacity>
    );

    return (
        <Menu
            ref={(ref) => { menuRef = ref }}
            button={menuTriggerButton}>
            {
                items.map(item => {
                    return (
                        <View>
                            <MenuItem
                                onPress={
                                    () => {
                                        menuRef?.hide();
                                        item.onPress();
                                    }
                                }>
                                <View style={styles.menuItem}>
                                    {
                                        item.icon
                                            ? <FontAwesome5Icon name={item.icon} style={styles.itemIcon} />
                                            : null
                                    }
                                    <Text style={styles.label}>{item.label}</Text>
                                </View>
                            </MenuItem>
                            {
                                item.hasDivider
                                    ? <MenuDivider />
                                    : null
                            }
                        </View>
                    )
                })
            }
        </Menu>
    )
}

const styles = StyleSheet.create({
    dropTrigger: {
        fontSize: 20,
        color: '#fff'
    },
    menuItem: {
        flex: 1,
        flexDirection: 'row',
        margin: 2
    },
    label: {
        fontSize: 16,
        flex: 10
    },
    itemIcon: {
        flex: 1,
        fontSize: 16,
        padding: 5,
        marginRight: 10
    },
});

export default DropMenu;
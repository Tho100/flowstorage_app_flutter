package com.crivlet.flowstorage

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "bluetooth_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getConnectedDevices" -> {
                    val connectedDeviceNames = getConnectedBluetoothDevices()
                    result.success(connectedDeviceNames)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getConnectedBluetoothDevices(): List<String> {
        val connectedDeviceNames = mutableListOf<String>()
        val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()

        bluetoothAdapter?.let {
            if (!it.isEnabled) {
                return connectedDeviceNames
            }

            for (device: BluetoothDevice in it.bondedDevices) {
                connectedDeviceNames.add(device.name)
            }
        }

        return connectedDeviceNames
    }
}

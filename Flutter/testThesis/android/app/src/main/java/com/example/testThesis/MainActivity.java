package com.example.testThesis;

import io.flutter.embedding.android.FlutterActivity;



//import io.flutter.embedding.android.FlutterActivity;

import androidx.annotation.NonNull;
 import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.util.Log;
import java.lang.Object;

import static android.content.Context.BATTERY_SERVICE;


public class MainActivity extends FlutterActivity implements SensorEventListener {
    private SensorManager sensorManager;
    private static final String CHANNEL = "samples.flutter.dev/battery";
    float batteryLevel = -1;
    private final float[] mRotationVectorReading = new float[3];
    private final float[] mRotationMatrix = new float[9];
    private final float[] mOrientationAngles = new float[3];
    private float[] mOrientation = new float[3];
    float mInitX, mX;
    private static final String TAG = "MyActivity";



    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getBatteryLevel")) {
                                sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
                                Sensor rotationVector = sensorManager.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR);
                                Sensor gyroscope = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);
                                if (gyroscope != null) {
                                    sensorManager.registerListener(this, gyroscope,
                                            SensorManager.SENSOR_DELAY_NORMAL, SensorManager.SENSOR_DELAY_UI);
                                sensorManager.registerListener(MainActivity.this,rotationVector,SensorManager.SENSOR_DELAY_NORMAL);
                                SensorManager.getOrientation(mRotationMatrix, mOrientationAngles);
                                if (batteryLevel != -1) {
                                    result.success(batteryLevel);
                                } else {
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            } else {
                                result.notImplemented();
                            }
                        }
                    }
                );
    }

    

    private void getBatteryLevel() {
        int batteryLevel = -1;
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            /*BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);*/
            sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
            Sensor rotationVector = sensorManager.getDefaultSensor(Sensor.TYPE_GAME_ROTATION_VECTOR);
            sensorManager.registerListener(MainActivity.this,rotationVector,SensorManager.SENSOR_DELAY_NORMAL, SensorManager.SENSOR_DELAY_UI);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }

        //return batteryLevel;
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {

    }

    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        if (sensorEvent.sensor.getType() == Sensor.TYPE_GAME_ROTATION_VECTOR) {
            System.arraycopy(sensorEvent.values, 0, mRotationVectorReading,
                    0, mRotationVectorReading.length);
        }
        //Log.d("value"+sensorEvent.values[0]);
        SensorManager.getRotationMatrixFromVector(mRotationMatrix, mRotationVectorReading);
        SensorManager.getOrientation(mRotationMatrix, mOrientationAngles);
                                mInitX = (float) (mOrientationAngles[0]*180.0F/Math.PI);
                                //LOGGER.i("orientationAngles",mOrientationAngles);
                                // Log.i(TAG,"mInitX: "+ mInitX);
                                // Log.i(TAG,"batterylevel: "+batteryLevel);
                                // Log.i(TAG,"orientation: "+mOrientationAngles[0]+mOrientationAngles[1]+mOrientationAngles[2]);
                                // Log.i(TAG,"matrix:"+mRotationMatrix[0]+mRotationMatrix[1]+mRotationMatrix[2]+mRotationMatrix[3]);
        batteryLevel = mInitX;
        // batteryLevel1 = sensorEvent.values[1];
        // batteryLevel2 = sensorEvent.values[2];
        //Log.d(TAG,"level is"+sensorEvent.values[0]+sensorEvent.values[1]+sensorEvent.values[2]);
    }
}

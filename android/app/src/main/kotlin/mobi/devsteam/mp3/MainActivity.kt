package mobi.devsteam.mp3

import android.Manifest
import android.content.ContentUris
import android.content.ContentValues
import android.media.RingtoneManager
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import java.io.File
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.provider.Settings
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mp3.devsteam.mobi/ringtone"

    private val REQUEST_CODE_WRITE_SETTINGS = 1534
    private val REQUEST_CODE_WRITE_SETTINGS_LESS_M = 1533
    private val REQUEST_CODE_STORAGE = 1536

    private var permissionsRequired = arrayOf(Manifest.permission.CAMERA, Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.READ_PHONE_STATE, Manifest.permission.WRITE_EXTERNAL_STORAGE)


    private lateinit var _result: MethodChannel.Result


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->

            println("CHANNEL")

            if (call.method == "checkPermissionWriteSettings") {
                _result = result
                checkPermissionWriteSettings()
            } else if (call.method == "checkPermissionStorage") {
                _result = result
                checkPermissionStorage()
            } else {

                println("Channel");
                val songPath = call.argument<String>("path") as String
                val songTitle = call.argument<String>("title") as String

                println(songTitle)

                if (call.method == "setRingtone") {
                    println("ringtone");
                    val setRingtoneAttempt = setAsRingtone(songPath, songTitle, isRingtone = true)
                    println(setRingtoneAttempt);
                    if (setRingtoneAttempt == "Succes") {
                        println("true");

                        result.success(true);
                    } else result.error("ERROR", setRingtoneAttempt, null)
                } else if (call.method == "setAlarm") {
                    val setRingtoneAttempt = setAsRingtone(songPath, songTitle, isAlarm = true)
                    if (setRingtoneAttempt == "Succes") {
                        result.success(true);
                    } else result.error("ERROR", setRingtoneAttempt, null)
                } else if (call.method == "setNotification") {
                    val setRingtoneAttempt = setAsRingtone(songPath, songTitle, isNotification = true)
                    if (setRingtoneAttempt == "Succes") {
                        result.success(true);
                    } else result.error("ERROR", setRingtoneAttempt, null)
                }
            }
        }
    }

    fun checkPermissionWriteSettings() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.System.canWrite(applicationContext)) {
                val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS, Uri.parse("package:$packageName"))
                startActivityForResult(intent, REQUEST_CODE_WRITE_SETTINGS)
            } else {
                _result.success(null)
            }
        } else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this,
                            Manifest.permission.WRITE_SETTINGS)
                    != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.WRITE_SETTINGS) as Array<String>, this.REQUEST_CODE_WRITE_SETTINGS_LESS_M);
            } else {
                _result.success(null)
            }
        }
    }

    fun checkPermissionStorage() {

        if (ContextCompat.checkSelfPermission(this,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE),
                    REQUEST_CODE_STORAGE)
        } else {
            _result.success(null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_WRITE_SETTINGS) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!Settings.System.canWrite(applicationContext)) {
                    _result.error("DENIED", "WRITE_SETTINGS", 0)
                } else {
                    _result.success(null)
                }
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        println("requestCode $requestCode")

        if (requestCode == REQUEST_CODE_STORAGE && grantResults[0] != PackageManager.PERMISSION_GRANTED) {
            _result.error("DENIED", "STORAGE", 1)
        } else if (requestCode == REQUEST_CODE_WRITE_SETTINGS_LESS_M && grantResults[0] != PackageManager.PERMISSION_GRANTED) {
            _result.error("DENIED", "SETTINGS", 2)
        } else
            _result.success(null)
    }


    fun setAsRingtone(songPath: String, songTitle: String, isRingtone: Boolean = false, isAlarm: Boolean = false, isNotification: Boolean = false): String {

        val songFile = File(songPath)

        var values = ContentValues()
        values.put(MediaStore.MediaColumns.DATA, songFile.absolutePath);
        values.put(MediaStore.MediaColumns.TITLE, songTitle);
        values.put(MediaStore.Audio.Media.ARTIST, "Rana");
        values.put(MediaStore.Audio.Media.TITLE, songTitle);
        values.put(MediaStore.MediaColumns.MIME_TYPE, "audio/mp3");
        values.put(MediaStore.MediaColumns.SIZE, songFile.length());
        values.put(MediaStore.Audio.Media.IS_RINGTONE, isRingtone);
        values.put(MediaStore.Audio.Media.IS_NOTIFICATION, isNotification);
        values.put(MediaStore.Audio.Media.IS_ALARM, isAlarm);
        values.put(MediaStore.Audio.Media.IS_MUSIC, false);

        var uri = MediaStore.Audio.Media.getContentUriForPath(songFile.absolutePath)

        val newUri: Uri?

        val cursor = this.getContentResolver().query(uri, null, MediaStore.MediaColumns.DATA + "=?", arrayOf(songFile.absolutePath) as Array<String>, null) as Cursor
        println("cursor: " + cursor)
        if (cursor != null && cursor.moveToFirst() && cursor.getCount() > 0) {
            val id = cursor.getString(0) as String
            this.getContentResolver().update(uri, values, MediaStore.MediaColumns.DATA + "=?", arrayOf(songFile.absolutePath) as Array<String>);
            newUri = ContentUris.withAppendedId(uri, id.toLong());
        } else {
            contentResolver.delete(uri, MediaStore.MediaColumns.DATA + "=\"" + songFile.absolutePath + "\"", null)
            newUri = this.getContentResolver().insert(MediaStore.Audio.Media.getContentUriForPath(songFile.absolutePath), values) as Uri
        }
        cursor.close()


        if (isRingtone) {

            try {
                RingtoneManager.setActualDefaultRingtoneUri(this, RingtoneManager.TYPE_RINGTONE, newUri)
                return ("Succes")
            } catch (t: Throwable) {
                return (t.message as String)
            }
        } else if (isAlarm) {
            try {
                RingtoneManager.setActualDefaultRingtoneUri(this, RingtoneManager.TYPE_ALARM, newUri)
                return ("Succes")
            } catch (t: Throwable) {
                return (t.message as String)
            }
        } else if (isNotification) {
            try {
                RingtoneManager.setActualDefaultRingtoneUri(this, RingtoneManager.TYPE_NOTIFICATION, newUri)
                return ("Succes")
            } catch (t: Throwable) {
                return (t.message as String)
            }
        }
        return ("Nothing happened");
    }
}
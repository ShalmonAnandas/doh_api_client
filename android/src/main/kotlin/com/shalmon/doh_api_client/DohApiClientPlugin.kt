package com.shalmon.doh_api_client

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/// IMPORTS for OKHTTP
import okhttp3.*
import okhttp3.OkHttpClient
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.dnsoverhttps.DnsOverHttps
import java.net.InetAddress
import java.io.IOException
import okhttp3.MediaType.Companion.toMediaTypeOrNull

/// ssl
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.security.cert.X509Certificate;
import javax.net.ssl.SSLSocketFactory;

/// DOH PRoviders
import com.shalmon.doh_api_client.dohCloudflare
import com.shalmon.doh_api_client.dohGoogle
import com.shalmon.doh_api_client.dohAdGuard
import com.shalmon.doh_api_client.dohQuad9
import com.shalmon.doh_api_client.dohAliDNS
import com.shalmon.doh_api_client.dohDNSPod
import com.shalmon.doh_api_client.doh360
import com.shalmon.doh_api_client.dohQuad101
import com.shalmon.doh_api_client.dohMullvad
import com.shalmon.doh_api_client.dohControlD
import com.shalmon.doh_api_client.dohNajalla
import com.shalmon.doh_api_client.dohSheCan

/** DohApiClientPlugin */
class DohApiClientPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "doh_api_client")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "makeGetRequest") {
            val url = call.argument<String>("url")
            val headers = call.argument<Map<String, String>>("headers")
            val dohProvider = call.argument<String>("dohProvider")!!
            if (url != null) {
                ApiClient(dohProvider).makeGetRequest(
                    url, headers ?: emptyMap()
                ) { response, error -> // Pass headers to ApiClient
                    if (error != null) {
                        result.error("GET_API_ERROR", error, null)
                    } else {
                        result.success(response)
                    }
                }
            }
        } else if (call.method == "makePostRequest") {
            val url = call.argument<String>("url")
            val headers = call.argument<Map<String, String>>("headers")
            val body = call.argument<String>("body")
            val dohProvider = call.argument<String>("dohProvider")!!
            if (url != null) {
                ApiClient(dohProvider).makePostRequest(
                    url, headers ?: emptyMap(), body
                ) { response, error -> // Pass headers to ApiClient
                    if (error != null) {
                        result.error("POST_API_ERROR", error, null)
                    } else {
                        result.success(response)
                    }
                }
            }
        } else if (call.method == "makePutRequest") {
            val url = call.argument<String>("url")
            val headers = call.argument<Map<String, String>>("headers")
            val body = call.argument<String>("body")
            val dohProvider = call.argument<String>("dohProvider")!!
            if (url != null) {
                ApiClient(dohProvider).makePutRequest(
                    url, headers ?: emptyMap(), body
                ) { response, error -> // Pass headers to ApiClient
                    if (error != null) {
                        result.error("PUT_API_ERROR", error, null)
                    } else {
                        result.success(response)
                    }
                }
            }
        } else if (call.method == "makePatchRequest") {
            val url = call.argument<String>("url")
            val headers = call.argument<Map<String, String>>("headers")
            val body = call.argument<String>("body")
            val dohProvider = call.argument<String>("dohProvider")!!
            if (url != null) {
                ApiClient(dohProvider).makePatchRequest(
                    url, headers ?: emptyMap(), body
                ) { response, error -> // Pass headers to ApiClient
                    if (error != null) {
                        result.error("PATCH_API_ERROR", error, null)
                    } else {
                        result.success(response)
                    }
                }
            }
        } else if (call.method == "makeDeleteRequest") {
            val url = call.argument<String>("url")
            val headers = call.argument<Map<String, String>>("headers")
            val dohProvider = call.argument<String>("dohProvider")!!
            if (url != null) {
                ApiClient(dohProvider).makeDeleteRequest(
                    url, headers ?: emptyMap()
                ) { response, error -> // Pass headers to ApiClient
                    if (error != null) {
                        result.error("DELETE_API_ERROR", error, null)
                    } else {
                        result.success(response)
                    }
                }
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

class ApiClient(dohProvider: String) {

    private val client: OkHttpClient

    init {

        // Create the OkHttpClient based on the selected DoH provider
        val dnsBuilder = when (dohProvider) {
            "CloudFlare" -> OkHttpClient.Builder().dohCloudflare().build()
            "Google" -> OkHttpClient.Builder().dohGoogle().build()
            "AdGuard" -> OkHttpClient.Builder().dohAdGuard().build()
            "Quad9" -> OkHttpClient.Builder().dohQuad9().build()
            "AliDNS" -> OkHttpClient.Builder().dohAliDNS().build()
            "DNSPod" -> OkHttpClient.Builder().dohDNSPod().build()
            "threeSixty" -> OkHttpClient.Builder().doh360().build()
            "Quad101" -> OkHttpClient.Builder().dohQuad101().build()
            "Mullvad" -> OkHttpClient.Builder().dohMullvad().build()
            "ControlD" -> OkHttpClient.Builder().dohControlD().build()
            "Najalla" -> OkHttpClient.Builder().dohNajalla().build()
            "SheCan" -> OkHttpClient.Builder().dohSheCan().build()
            else -> OkHttpClient.Builder().dohCloudflare().build() // Default to Cloudflare
        }

        client = dnsBuilder
    }

    fun makeGetRequest(
        url: String, headers: Map<String, String>, result: (String?, String?) -> Unit
    ) {
        println(client)
        val builder = okhttp3.Request.Builder().url(url)

        for ((key, value) in headers) {
            builder.addHeader(key, value)
        }

        val request = builder.build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: java.io.IOException) {
                result(null, e.message)
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (!response.isSuccessful) {
                    result(null, response.message)
                    return
                }
                response.body?.string()?.let {
                    result(it, null)
                }
            }
        })
    }

    fun makePostRequest(
        url: String, headers: Map<String, String>, body: String?, result: (String?, String?) -> Unit
    ) {
        val builder = okhttp3.Request.Builder().url(url)

        for ((key, value) in headers) {
            builder.addHeader(key, value)
        }

        // Add body to the request
        val requestBody: RequestBody =
            body?.let { okhttp3.RequestBody.create("application/json".toMediaTypeOrNull(), it) }!!
        val request = builder.post(requestBody).build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: java.io.IOException) {
                result(null, e.message)
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (!response.isSuccessful) {
                    result(null, response.message)
                    return
                }
                response.body?.string()?.let {
                    result(it, null)
                }
            }
        })
    }

    fun makePutRequest(
        url: String, headers: Map<String, String>, body: String?, result: (String?, String?) -> Unit
    ) {
        val builder = okhttp3.Request.Builder().url(url)

        for ((key, value) in headers) {
            builder.addHeader(key, value)
        }

        // Add body to the request
        val requestBody: RequestBody =
            body?.let { okhttp3.RequestBody.create("application/json".toMediaTypeOrNull(), it) }!!
        val request = builder.put(requestBody).build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: java.io.IOException) {
                result(null, e.message)
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (!response.isSuccessful) {
                    result(null, response.message)
                    return
                }
                response.body?.string()?.let {
                    result(it, null)
                }
            }
        })
    }

    fun makePatchRequest(
        url: String, headers: Map<String, String>, body: String?, result: (String?, String?) -> Unit
    ) {
        val builder = okhttp3.Request.Builder().url(url)

        for ((key, value) in headers) {
            builder.addHeader(key, value)
        }

        // Add body to the request
        val requestBody: RequestBody =
            body?.let { okhttp3.RequestBody.create("application/json".toMediaTypeOrNull(), it) }!!
        val request = builder.patch(requestBody).build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: java.io.IOException) {
                result(null, e.message)
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (!response.isSuccessful) {
                    result(null, response.message)
                    return
                }
                response.body?.string()?.let {
                    result(it, null)
                }
            }
        })
    }

    fun makeDeleteRequest(
        url: String, headers: Map<String, String>, result: (String?, String?) -> Unit
    ) {
        val builder = okhttp3.Request.Builder().url(url)

        for ((key, value) in headers) {
            builder.addHeader(key, value)
        }

        val request = builder.delete().build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: java.io.IOException) {
                result(null, e.message)
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (!response.isSuccessful) {
                    result(null, response.message)
                    return
                }
                response.body?.string()?.let {
                    result(it, null)
                }
            }
        })
    }
}
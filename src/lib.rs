use std::ffi::CStr;
use std::os::raw::c_char;
use whatlang::detect;

#[repr(C)]
pub struct DetectionResult {
    pub lang_code: [c_char; 4],   // 3 chars for ISO-639-3 + null terminator
    pub script_name: [c_char; 16], // Room for strings like "Latin", "Cyrillic"
    pub confidence: f64,          // 64-bit float for precision score
    pub success: u8,              // Boolean flag: 1 if found, 0 if failed
}

#[no_mangle]
pub extern "C" fn detect_language_ext(text_ptr: *const c_char, out: *mut DetectionResult) {
    if text_ptr.is_null() || out.is_null() { return; }

    let out_struct = unsafe { &mut *out };
    out_struct.success = 0; // Default to fail

    let c_str = unsafe { CStr::from_ptr(text_ptr) };
    let text = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return,
    };

    if let Some(info) = detect(text) {
        let lang = info.lang().code();
        let script = format!("{:?}", info.script()); // e.g., "Latin"
        let conf = info.confidence();

        // Write language code safely
        for (i, byte) in lang.bytes().enumerate().take(3) {
            out_struct.lang_code[i] = byte as c_char;
        }
        out_struct.lang_code[lang.len().min(3)] = 0; // Explicit null terminator

        // Write script name safely
        for (i, byte) in script.bytes().enumerate().take(15) {
            out_struct.script_name[i] = byte as c_char;
        }
        out_struct.script_name[script.len().min(15)] = 0; // Explicit null terminator

        out_struct.confidence = conf;
        out_struct.success = 1;
    }
}


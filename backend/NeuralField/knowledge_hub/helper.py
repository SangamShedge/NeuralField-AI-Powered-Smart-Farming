def get_lang_value(field, lang):
    if isinstance(field, dict):
        return field.get(lang, field.get("en"))
    return field
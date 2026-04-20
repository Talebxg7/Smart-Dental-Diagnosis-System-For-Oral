<?php
/**
 * Basic input validation for API payloads.
 */
declare(strict_types=1);

namespace Utils;

final class Validator
{
    public static function required(array $data, array $keys): ?string
    {
        foreach ($keys as $key) {
            if (!isset($data[$key]) || trim((string) $data[$key]) === '') {
                return "Missing or empty field: {$key}";
            }
        }
        return null;
    }

    public static function email(string $email): bool
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    public static function phone(string $phone): bool
    {
        $digits = preg_replace('/\D/', '', $phone);
        return $digits !== '' && strlen($digits) >= 8 && strlen($digits) <= 15;
    }

    public static function passwordMinLength(string $password, int $min = 6): bool
    {
        return strlen($password) >= $min;
    }

    public static function intPositive($value): bool
    {
        if ($value === null || $value === '') {
            return false;
        }
        $n = filter_var($value, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
        return $n !== false;
    }

    public static function floatNonNegative($value): bool
    {
        if ($value === null || $value === '') {
            return false;
        }
        if (!is_numeric($value)) {
            return false;
        }
        return (float) $value >= 0.0;
    }
}

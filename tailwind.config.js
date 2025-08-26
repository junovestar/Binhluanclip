/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'radar-blue': '#1a237e',
        'radar-purple': '#4a148c',
        'accent-blue': '#2196f3',
        'accent-cyan': '#00bcd4',
        'glow': '#64ffda'
      },
      animation: {
        'pulse-glow': 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'radar-sweep': 'spin 4s linear infinite',
        'ping-ripple': 'ping 1s cubic-bezier(0, 0, 0.2, 1) infinite'
      },
      boxShadow: {
        'glow': '0 0 20px rgba(100, 255, 218, 0.5)',
        'glow-strong': '0 0 40px rgba(100, 255, 218, 0.8)'
      }
    },
  },
  plugins: [],
}

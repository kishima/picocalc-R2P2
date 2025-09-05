(async function(global) {
  async function initPicoRuby() {
    // Import the factory function
    const baseURL = document.currentScript?.src ? new URL('.', document.currentScript.src).href : '';
    const { default: createModule } = await import(baseURL + 'picoruby.js');

    async function collectRubyScripts() {
      const rubyScripts = document.querySelectorAll('script[type="text/ruby"]');
      const taskPromises = Array.from(rubyScripts).map(async script => {
        if (script.src) {
          const response = await fetch(script.src);
          if (!response.ok) {
            throw new Error(`Failed to load ${script.src}: ${response.statusText}`);
          }
          return await response.text();
        }
        return script.textContent.trim();
      });
      return Promise.all(taskPromises);
    }

    // Create and initialize the module
    const Module = await createModule();
    Module.picorubyRun = function() {
      const tickTimer = setInterval(() => {
        Module.ccall('mrbc_tick', null, [], []);
      }, 17); // 16.67ms: optimize for 60fps. See MRBC_TICK_UNIT in build_config/wasm.rb

      function run() {
        const result = Module.ccall('mrbc_run_step', 'number', [], []);
        if (result < 0) {
          return;
        }
        setTimeout(run, 0);
      }
      run();
    };

    // Initialize WASM and start tasks
    Module.ccall('picorb_init', 'number', [], []);

    // Collect and create tasks from Ruby script tags
    try {
      const rubyTasks = await collectRubyScripts();
      rubyTasks.forEach(function(task) {
        Module.ccall('picorb_create_task', 'number', ['string'], [task]);
      });
    } catch (error) {
      console.error('Error loading Ruby tasks:', error);
    }

    // Also support window.userTasks if present (for backward compatibility)
    if (window.userTasks) {
      window.userTasks.forEach(function(task) {
        Module.ccall('picoruby_create_task', 'number', ['string'], [task]);
      });
    }

    // Start PicoRuby execution
    Module.picorubyRun();
  }

  global.initPicoRuby = initPicoRuby;

  await initPicoRuby();
})(typeof window !== 'undefined' ? window : this).catch(console.error);

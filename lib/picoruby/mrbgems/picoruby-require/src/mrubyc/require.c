#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <mrubyc.h>

typedef struct picogems {
  const char *name;
  const uint8_t *mrb;
  void (*initializer)(mrbc_vm *vm);
  bool required;
} picogems;

extern picogems prebuilt_gems[];

static bool
picoruby_load_model(const uint8_t *mrb)
{
  mrbc_vm *vm = mrbc_vm_open(NULL);
  if (vm == 0) {
    console_printf("Error: Can't open VM.\n");
    return false;
  }
  if (mrbc_load_mrb(vm, mrb) != 0) {
    console_printf("Error: %s\n", vm->exception.exception->message);
    mrbc_vm_close(vm);
    return false;
  }
  mrbc_vm_begin(vm);
  mrbc_vm_run(vm);
  if (vm->exception.tt != MRBC_TT_NIL) {
    console_printf("Error: Exception occurred.\n");
    mrbc_vm_end(vm);
    mrbc_vm_close(vm);
    return false;
  }
  mrbc_raw_free(vm);
  return true;
}

static int
gem_index(const char *name)
{
  if (!name) return -1;
  for (int i = 0; ; i++) {
    if (prebuilt_gems[i].name == NULL) {
      return -1;
    } else if (strcmp(name, prebuilt_gems[i].name) == 0) {
      return i;
    }
  }
}

static void
c_extern(mrbc_vm *vm, mrbc_value *v, int argc)
{
  if (argc == 0 || 2 < argc) {
    mrbc_raise(vm, MRBC_CLASS(ArgumentError), "wrong number of arguments (expected 1..2)");
    return;
  }
  if (GET_TT_ARG(1) != MRBC_TT_STRING) {
    mrbc_raise(vm, MRBC_CLASS(TypeError), "wrong argument type");
    return;
  }
  const char *name = (const char *)GET_STRING_ARG(1);
  int i = gem_index(name);
  if (i < 0) {
    SET_NIL_RETURN();
    return;
  }
  bool force = false;
  if (argc == 2 && GET_TT_ARG(2) == MRBC_TT_TRUE) {
    force = true;
  }
  if ((force || !prebuilt_gems[i].required)) {
    if (prebuilt_gems[i].initializer) prebuilt_gems[i].initializer(vm);
    if (!picoruby_load_model(prebuilt_gems[i].mrb)) {
      SET_NIL_RETURN();
    } else {
      prebuilt_gems[i].required = true;
      SET_TRUE_RETURN();
    }
  } else {
    SET_FALSE_RETURN();
  }
}

/* public API */

bool
picoruby_load_model_by_name(const char *gem)
{
  int i = gem_index(gem);
  if (i < 0) return false;
  return picoruby_load_model(prebuilt_gems[i].mrb);
}

void
picoruby_init_require(mrbc_vm *vm)
{
  mrbc_class *module_Kernel = mrbc_define_module(vm, "Kernel");
  mrbc_define_method(vm, module_Kernel, "extern", c_extern);
  mrbc_value self = mrbc_instance_new(vm, mrbc_class_object, 0);
  mrbc_instance_call_initialize(vm, &self, 0);
  mrbc_value args[2];
  args[0] = self;
  args[1] = mrbc_string_new_cstr(vm, "require");
  c_extern(vm, args, 1);
  args[1] = mrbc_string_new_cstr(vm, "io");
  c_extern(vm, args, 1);
}

void
mrbc_require_init(mrbc_vm *vm)
{
  // This must be empty because `require` cannot require itself.
  // The initialization of `require` is done in `picoruby_init_require`,
  // which should be called from the application's main entry point
  // after the VM is initialized.
}

